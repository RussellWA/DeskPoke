extends CharacterBody2D

class_name Pet

var window_size: Vector2i

var pokemon_data: PokeData

@onready var movement_controller = $MovementController
@onready var animation_controller = $AnimationController
@onready var behavior_controller = $BehaviorController
@onready var right_click_menu: PopupMenu = $RightClickMenu

@export var pet_scale := 10.0

func _ready() -> void:
	window_size = get_window().size
	scale = Vector2.ONE * pet_scale
	
	get_viewport().transparent_bg = true

func setup(data: PokeData):
	pokemon_data = data
	animation_controller.setup(data)
	behavior_controller.start(data)

func _physics_process(_delta: float) -> void:
	velocity = movement_controller.get_velocity()
	move_and_slide()

func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var mouse_pos = get_viewport().get_mouse_position()
			
			right_click_menu.position = mouse_pos
			right_click_menu.popup()

func _on_right_click_menu_id_pressed(id: int) -> void:
	match id:
		0: # Scale Up (matches the ID we set in _ready)
			scale += Vector2(0.5, 0.5)
		1: # Scale Down
			if scale.x > 0.5: # Prevent shrinking to nothing
				scale -= Vector2(0.5, 0.5)
