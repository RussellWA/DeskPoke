extends CharacterBody2D

class_name Pet

@onready var pokeball_sprite = $PokeballSprite
@onready var anim_sprite = $AnimatedSprite2D

signal on_right_clicked(pet_node: Node)
signal on_despawned
var is_despawning: bool = false

var window_size: Vector2i

var pokemon_data: PokeData

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var gravity: float = 1200.0

@onready var movement_controller = $MovementController
@onready var animation_controller = $AnimationController
@onready var behavior_controller = $BehaviorController

@export var pet_scale := 5.0

func _ready() -> void:
	window_size = get_window().size
	scale = Vector2.ONE * pet_scale

	get_viewport().transparent_bg = true

func setup(data: PokeData):
	pokemon_data = data
	animation_controller.setup(data)
	behavior_controller.setup(data)

func _physics_process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		velocity = Vector2.ZERO
	else:
		var controller_vel = movement_controller.get_velocity()

		velocity.x = controller_vel.x

		velocity.y += gravity * delta

		move_and_slide()
		
		var ground_y = DesktopController.get_ground_y()

		if global_position.y > ground_y:
			global_position.y = ground_y
			velocity.y = 0

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_despawning:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				behavior_controller.enter_dragged()
				#drag_offset = global_position - get_global_mouse_position()
				#velocity = Vector2.ZERO
			else:
				is_dragging = false
				behavior_controller.exit_dragged()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			on_right_clicked.emit(self)

func despawn() -> void:
	if is_despawning:
		return

	is_despawning = true
	is_dragging = false # Release mouse lock immediately

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)

func check_if_on_floor() -> bool:
	var ground_y = DesktopController.get_ground_y()
	if global_position.y == ground_y:
		return true
	return false

func get_scaled_width() -> float:
	if animation_controller:
		return animation_controller.calculated_width * scale.x
	return 32.0 * scale.x

func spawn_sequence(spawn_position: Vector2) -> void:
	global_position = spawn_position
	
	behavior_controller.set_physics_process(false)
	animation_controller.load_animation("Idle")
	anim_sprite.pause()
	anim_sprite.frame = 0
	
	var ball_tex = pokeball_sprite.sprite_frames.get_frame_texture("open", 0)
	if ball_tex != null:
		pokeball_sprite.position.y = -(ball_tex.get_height() / 2.0)
	
	pokeball_sprite.frame = 0
	pokeball_sprite.scale = Vector2.ZERO
	pokeball_sprite.modulate.a = 1.0
	pokeball_sprite.show()
	
	anim_sprite.scale = Vector2.ZERO
	anim_sprite.modulate = Color(5.0, 1.0, 1.0)
	
	var ball_tween = create_tween()
	ball_tween.tween_property(pokeball_sprite, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await ball_tween.finished
	
	await get_tree().create_timer(0.4).timeout
	
	pokeball_sprite.frame = 1
	
	await get_tree().create_timer(0.1).timeout
	
	var pet_tween = create_tween().set_parallel(true)
	pet_tween.tween_property(anim_sprite, "scale", Vector2.ONE, 0.8)\
		.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	pet_tween.tween_property(anim_sprite, "modulate", Color.WHITE, 0.8)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pet_tween.tween_property(pokeball_sprite, "modulate:a", 0.0, 0.5)
	
	await pet_tween.finished
	pokeball_sprite.hide()
	
	behavior_controller.set_physics_process(true)
	behavior_controller.enter_idle()


func recall_sequence() -> void:
	if is_despawning:
		return
	is_despawning = true
	
	behavior_controller.set_physics_process(false)
	anim_sprite.pause()
	
	var ball_tex = pokeball_sprite.sprite_frames.get_frame_texture("open", 0)
	if ball_tex != null:
		pokeball_sprite.position.y = -(ball_tex.get_height() / 2.0)

	pokeball_sprite.frame = 1
	pokeball_sprite.scale = Vector2.ONE
	pokeball_sprite.modulate.a = 0.0
	pokeball_sprite.show()
	
	var setup_tween = create_tween().set_parallel(true)
	setup_tween.tween_property(pokeball_sprite, "modulate:a", 1.0, 0.4)
	setup_tween.tween_property(anim_sprite, "modulate", Color(10.0, 0.1, 0.1), 0.4)
	await setup_tween.finished

	var suck_tween = create_tween()
	suck_tween.tween_property(anim_sprite, "scale", Vector2.ZERO, 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await suck_tween.finished
	
	pokeball_sprite.frame = 0
	var ball_tween = create_tween()
	ball_tween.tween_property(pokeball_sprite, "scale", Vector2.ZERO, 0.3)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await ball_tween.finished
	
	queue_free()
