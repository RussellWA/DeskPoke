extends CharacterBody2D

class_name Pet

var window_size: Vector2i

@onready var movement_controller = $MovementController

func _ready() -> void:
	window_size = get_window().size
	
	get_viewport().transparent_bg = true

func _physics_process(_delta: float) -> void:
	velocity = movement_controller.get_velocity()
	move_and_slide()
	
