extends Node

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
var pokemon_data: PokeData
var current_animation: AnimationData

func setup(data: PokeData):
	pokemon_data = data

func load_animation(animation_name: String):
	var anim: AnimationData = pokemon_data.animations[animation_name]

	sprite.sprite_frames = anim.sprite_frames
	play(animation_name)

func enter_idle():
	load_animation("Pose")

func enter_walk(dir: int):
	if dir == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

	load_animation("Walk")

func play(animation_name: String):
	current_animation = pokemon_data.animations[animation_name]

	sprite.sprite_frames = current_animation.sprite_frames
	sprite.play(animation_name)

func get_current_offset() -> FrameOffset:
	if current_animation == null:
		return null

	return current_animation.offsets[sprite.frame]

func _process(_delta):
	var offset = get_current_offset()
	if offset != null:
		var center = Vector2(
			current_animation.frame_width / 2.0,
			current_animation.frame_height / 2.0
		)

		sprite.position = center - Vector2(offset.body)
