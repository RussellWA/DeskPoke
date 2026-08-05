extends CharacterBody2D

class_name Pet

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
	behavior_controller.start(data)

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
