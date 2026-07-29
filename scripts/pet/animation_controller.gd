extends Node

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

func load_animation(data: PokeData, animation_name: String):
	var anim: AnimationData = data.animations[animation_name]

	sprite.sprite_frames = anim.sprite_frames
	sprite.play(animation_name)

func enter_idle() -> void:
	sprite.play("Pose")

func enter_walk(dir: int) -> void:
	if dir == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	sprite.play("Walk")
