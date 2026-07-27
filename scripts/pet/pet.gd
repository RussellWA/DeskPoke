extends CharacterBody2D

class_name Pet

var window_size: Vector2i

@onready var movement_controller = $MovementController

func _ready() -> void:
	window_size = get_window().size
	
	# Sizes of sprites are halved because its from the center
	movement_controller.left_limit = $Sprite2D.get_rect().size.x / 2
	movement_controller.right_limit = window_size.x - ($Sprite2D.get_rect().size.x / 2)
	
	get_viewport().transparent_bg = true

func _physics_process(_delta: float) -> void:
	velocity = movement_controller.get_velocity()
	move_and_slide()
	
