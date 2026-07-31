extends CharacterBody2D

class_name Pet

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

		if global_position.y > DesktopController.get_ground_y(): 
			global_position.y = DesktopController.get_ground_y()
			velocity.y = 0

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()
			velocity = Vector2.ZERO
		else:
			is_dragging = false
