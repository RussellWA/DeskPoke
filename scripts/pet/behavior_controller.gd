extends Node

@onready var pet = get_parent()
@onready var movement_controller = $"../MovementController"
@onready var animation_controller = $"../AnimationController"

@onready var timer: Timer = $Timer 

var pokemon_data: PokeData

enum State {
	IDLE,
	WALKING,
	SLEEPING,
	WAKING_UP,
	DRAGGED,
	FALLING,
	LANDING
}

var max_energy: float = 100.0
var energy: float = 100.0

var state: State
var idle_anims: Array[String] = []
var possible_idles = ["Idle", "Pose", "Nod", "Hop", "Twirl"]

func start(data: PokeData) -> void:
	pokemon_data = data
	
	idle_anims.clear()
	
	for anim_name in possible_idles:
		if pokemon_data.animations.has(anim_name):
			idle_anims.append(anim_name)
	
	if idle_anims.is_empty():
		push_warning("No idle animations found for " + pokemon_data.name)
	
	enter_walking()

func _on_timer_timeout():
	match state:
		State.IDLE:
			enter_walking()
		State.WALKING:
			enter_idle()

func enter_idle() -> void:
	state = State.IDLE
	movement_controller.stop()
	var random_idle = idle_anims.pick_random()
	animation_controller.enter_idle(random_idle)
	timer.start(4)

func enter_walking() -> void:
	state = State.WALKING
	var random_dir = [-1, 1].pick_random()
	animation_controller.enter_walk(random_dir)
	movement_controller.walk(random_dir)
	timer.start(6)

func _on_movement_controller_hit_left() -> void:
	movement_controller.walk(1)
	animation_controller.enter_walk(1)

func _on_movement_controller_hit_right() -> void:
	movement_controller.walk(-1)
	animation_controller.enter_walk(-1)

func _physics_process(delta: float) -> void:
	if not pet or pet.is_despawning:
		return
	
	if state == State.DRAGGED:
		return

	if not pet.check_if_on_floor():
		pet.velocity.y += 980 * delta
	else:
		pet.global_position.y = DesktopController.get_ground_y()
		pet.velocity.y = 0 
		pet.velocity.x = 0

	match state:
		State.FALLING:
			if pet.check_if_on_floor():
				hit_the_ground()
			
		State.SLEEPING:
			energy += 15.0 * delta 
			pet.velocity.x = 0
			
			if energy >= max_energy:
				wake_up()
				
		State.WALKING:
			energy -= 10.0 * delta
			
			if energy <= 0:
				go_to_sleep()
				
	pet.move_and_slide()

func go_to_sleep() -> void:
	state = State.SLEEPING
	timer.stop()
	movement_controller.stop()
	animation_controller.play_sleep_sequence()

func wake_up() -> void:
	state = State.WAKING_UP
	await animation_controller.play_wake_sequence()
	enter_idle()

func enter_dragged() -> void:
	state = State.DRAGGED
	timer.stop()
	movement_controller.stop()
	pet.velocity = Vector2.ZERO
	animation_controller.enter_dragged()

func exit_dragged() -> void:
	state = State.FALLING
	
func hit_the_ground() -> void:
	state = State.LANDING
	await animation_controller.play_landing_sequence()
	wake_up()
