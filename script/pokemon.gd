extends CharacterBody2D

# --- SIGNAL ---
signal request_menu(pet_node)

# --- CONFIGURATION ---
var walk_speed = 60.0
var gravity = 1500.0
@export var y_offset = 42.0

# --- STATE MANAGEMENT ---
# Added IMPACT state for that moment they hit the ground
enum { IDLE, WALK_LEFT, WALK_RIGHT, DRAGGED, FALLING, IMPACT, LANDING, SLEEP, TO_SLEEP, WAKING }
var current_idle_anim = "idle"
var current_state = IDLE
var state_timer = 0.0

# --- ENERGY SYSTEM ---
#var energy = 50
#var max_energy = 50.0
var energy = 1500
var max_energy = 1500.0
var energy_drain_rate = 5.0   # How fast it gets tired (per second)
var energy_regen_rate = 10.0  # How fast it recovers when sleeping

@export var anim_offsets = {
	"idle": 0,
	"walk": 0,
	"dragged": 0,
	"fall": 9,
	"get_up": -7,
	"deep_breath": 0,
	"pose": -4,
	"sleep": -7,
	"wake": -7,
	"recover": 9,
}

# --- REFERENCES ---
@onready var anim = $AnimatedSprite2D
var drag_offset = Vector2.ZERO
var floor_y = 0.0

func _ready():
	randomize()
	if floor_y == 0.0:
		floor_y = get_viewport_rect().size.y

	# Snap to floor immediately on start so we don't trigger the sequence
	var real_half_height = (get_current_size().y / 2.0)
	global_position.y = (floor_y + y_offset) - real_half_height
	
	# Connect the signal (Crucial for the sequence!)
	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)
	
	if randf() < 0.5:
		current_state = WALK_LEFT
	else:
		current_state = WALK_RIGHT
		
	# Set the timer so it walks for 3-6 seconds before changing its mind
	state_timer = randf_range(3.0, 6.0)

func _physics_process(delta):
	# 1. DRAGGING (Overrides everything, even Sleep!)
	if current_state == DRAGGED:
		global_position = get_global_mouse_position() + drag_offset
		velocity = Vector2.ZERO
		play_anim("dragged")
		return

	# 2. SLEEPING BEHAVIOR (Regen)
	if current_state == SLEEP:
		velocity.x = 0
		velocity.y = 0
		play_anim("sleep") # Make sure you have a "sleep" animation!
		
		# Regenerate Energy
		energy += energy_regen_rate * delta
		
		# Wake up ONLY if fully charged
		if energy >= max_energy:
			energy = max_energy
			wake_up()
			
		# Gravity still applies (so they don't float if the floor moves)
		# But usually sleeping pets are static. Let's keep gravity just in case.
		velocity.y += gravity * delta
		move_and_slide()
		
		# Keep clamped to floor
		clamp_to_floor() 
		return

	# 3. IMPACT, LANDING, YAWNING, & WAKING (Frozen states)
	if current_state in [IMPACT, LANDING, TO_SLEEP, WAKING]:
		velocity.x = 0
		velocity.y = 0
		return

	# 4. GRAVITY & FALLING
	velocity.y += gravity * delta
	if velocity.y > 500 and current_state != FALLING:
		current_state = FALLING
		play_anim("fall")

	# 5. ACTIVE BEHAVIOR (Drain Energy)
	if current_state in [IDLE, WALK_LEFT, WALK_RIGHT]:
		
		# --- ENERGY DRAIN ---
		energy -= energy_drain_rate * delta
		if energy <= 0:
			energy = 0
			start_sleeping() # Force sleep immediately
		# --------------------

		if current_state == IDLE:
			velocity.x = move_toward(velocity.x, 0, walk_speed)
			play_anim(current_idle_anim)
		elif current_state == WALK_LEFT:
			velocity.x = -walk_speed
			play_anim("walk")
			anim.flip_h = true
		elif current_state == WALK_RIGHT:
			velocity.x = walk_speed
			play_anim("walk")
			anim.flip_h = false

	# 6. MOVE
	move_and_slide()

	# 7. FLOOR CLAMPING logic (Extracted to helper function for cleanliness)
	clamp_to_floor()

	# 8. SCREEN BOUNDS
	var screen_width = get_viewport_rect().size.x
	var half_w = get_current_size().x / 2.0
	
	if global_position.x < half_w:
		global_position.x = half_w
		if current_state in [WALK_LEFT, WALK_RIGHT]: force_change_state(WALK_RIGHT)
	elif global_position.x > screen_width - half_w:
		global_position.x = screen_width - half_w
		if current_state in [WALK_LEFT, WALK_RIGHT]: force_change_state(WALK_LEFT)

	# 9. TIMER (Only run if active)
	if current_state in [IDLE, WALK_LEFT, WALK_RIGHT]:
		state_timer -= delta
		if state_timer <= 0:
			pick_random_state()

# --- THE SEQUENCE LOGIC ---

func start_impact_sequence():
	# Step 1: Hit ground, lie down
	current_state = IMPACT
	play_anim("fall") 
	# IMPORTANT: If "fall" is set to Loop in editor, 
	# this signal will NEVER fire. You must turn off Loop for "fall"!

func _on_animation_finished():
	# 1. IMPACT -> RECOVER (The "Falling" Chain)
	if current_state == IMPACT and anim.animation == "fall":
		current_state = LANDING
		play_anim("recover")
		
	# 2. TO_SLEEP -> SLEEP (The "Sleeping" Chain)
	elif current_state == TO_SLEEP and anim.animation == "deep_breath":
		current_state = SLEEP
		play_anim("sleep")

	# 3. WAKE -> GET_UP (The "Waking Up" Chain)
	elif current_state == WAKING and anim.animation == "wake":
		# Transition to Landing state so it plays "get_up" next
		current_state = LANDING
		play_anim("get_up")

	# 4. GET_UP -> WALK (Shared by both Falling and Waking chains)
	elif current_state == LANDING and (anim.animation == "recover" or anim.animation == "get_up"):
		
		# Force a walk immediately after standing up
		if randf() < 0.5:
			current_state = WALK_LEFT
		else:
			current_state = WALK_RIGHT
			
		# Set walk duration
		state_timer = randf_range(3.0, 6.0)

# --- HELPER FUNCTIONS ---

func pick_random_state():
	var roll = randf()
	if roll < 0.5:
		current_state = IDLE
		state_timer = randf_range(2.0, 5.0)
		current_idle_anim = ["idle", "pose"].pick_random()
	else:
		if randf() < 0.5: current_state = WALK_LEFT
		else: current_state = WALK_RIGHT
		state_timer = randf_range(3.0, 6.0)

func force_change_state(new_state):
	current_state = new_state
	state_timer = randf_range(2.0, 4.0)

func play_anim(anim_name):
	# FIX: Add "or not anim.is_playing()" to catch those frozen moments
	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)
		
		# Apply the custom offset
		if anim_name in anim_offsets:
			anim.offset.y = anim_offsets[anim_name]
		else:
			anim.offset.y = 0

func start_sleeping():
	current_state = TO_SLEEP
	velocity = Vector2.ZERO
	play_anim("deep_breath") # Make sure Loop is OFF for this!

func wake_up():
	# 1. Switch to Waking state
	current_state = WAKING
	# 2. Play the Wake animation
	play_anim("wake") 

# I extracted the messy floor logic here to keep process clean
func clamp_to_floor():
	var real_half_height = (get_current_size().y / 2.0)
	var target_y = floor_y + y_offset
	
	if global_position.y + real_half_height >= target_y:
		global_position.y = target_y - real_half_height
		velocity.y = 0
		
		if current_state == FALLING:
			start_impact_sequence()

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		
		# LEFT CLICK = DRAG
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				current_state = DRAGGED
				drag_offset = global_position - get_global_mouse_position()
			else:
				current_state = FALLING # Start falling immediately
		
		# RIGHT CLICK = MENU (New!)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			emit_signal("request_menu", self)

func get_current_size():
	# Safety Check 1: Does the 'anim' node exist?
	if not is_instance_valid(anim):
		return Vector2(100, 100) # Return default if node is missing

	# Safety Check 2: Does it have frames loaded?
	if anim.sprite_frames:
		var tex = anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
		# Safety Check 3: Is the texture valid?
		if tex: 
			# Your calculation was correct:
			return tex.get_size() * anim.scale * scale
			
	return Vector2(100, 100)
