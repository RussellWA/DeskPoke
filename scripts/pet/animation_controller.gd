extends Node

@onready var sprite = $"../AnimatedSprite2D"

func enter_idle() -> void:
	sprite.play("pose")

func enter_walk(dir: int) -> void:
	if dir == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	sprite.play("walk_right")
