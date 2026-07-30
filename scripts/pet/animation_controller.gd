extends Node

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
var pokemon_data: PokeData

func setup(data: PokeData):
	pokemon_data = data
	sprite.position.y = -pokemon_data.ground_offset

func load_animation(animation_name: String):
	var anim: AnimationData = pokemon_data.animations[animation_name]

	sprite.sprite_frames = anim.sprite_frames
	
	# Get the center of the frame (e.g., 40 / 2 = 20)
	var center_y = anim.frame_height / 2.0
	
	# anim.ground_offset is now the exact coordinate of the feet (e.g., 28)
	# Formula: Center - Lowest Pixel (e.g., 20 - 28 = -8)
	sprite.offset.y = center_y - anim.ground_offset
	
	print("offset: ", sprite.offset.y)
		
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
	sprite.play(animation_name)
