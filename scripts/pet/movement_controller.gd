extends Node

# Signals
signal hit_left
signal hit_right

@onready var pet = get_parent()

# Configs
var speed: float = 60.0
var direction: int = 1
#var gravity: float = 1500.0
var moving: bool = false
var left_limit: int
var right_limit: int

func _physics_process(_delta: float) -> void:
	if pet.position.x <= left_limit:
		hit_left.emit()
	
	if pet.position.x >= right_limit:
		hit_right.emit()

func walk(dir: int):
	direction = dir
	moving = true

func stop():
	moving = false

func is_moving() -> bool:
	return moving

func get_direction() -> int:
	return direction

func set_speed(newSpeed: float):
	speed = newSpeed
	
func get_velocity():
	if moving:
		return Vector2(speed * direction, 0)
	else:
		return Vector2(0, 0)
