extends Node

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
var pokemon_data: PokeData

func setup(data: PokeData):
	pokemon_data = data
	sprite.position.y = -pokemon_data.ground_offset

func load_animation(animation_name: String):
	var anim: AnimationData = pokemon_data.animations[animation_name]

	sprite.sprite_frames = anim.sprite_frames
	
	var center_y = anim.frame_height / 2.0
	
	sprite.offset.y = center_y - anim.ground_offset
		
	play(animation_name)

func enter_idle(anim: String):
	load_animation(anim)

func enter_walk(dir: int):
	if dir == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	load_animation("Walk")

func play(animation_name: String):
	sprite.play(animation_name)
