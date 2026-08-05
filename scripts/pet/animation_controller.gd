extends Node

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var collision: CollisionShape2D = $"../CollisionShape2D"

var pokemon_data: PokeData

var animation_speeds: Dictionary = {
	"Walk": 10.0,
	"DeepBreath": 5.0,
	"Wake": 5.0,
	"Idle": 8.0,
	"Nod": 7.0,
	"Hop": 10.0,
	"Pose": 10.0,
	"Twirl": 10.0,
	"Sleep": 2.0,
	"EventSleep": 3.0,
	"Landing": 5.0,
}

func setup(data: PokeData):
	pokemon_data = data
	sprite.position.y = -pokemon_data.ground_offset

func load_animation(animation_name: String):
	var anim: AnimationData = pokemon_data.animations[animation_name]

	sprite.sprite_frames = anim.sprite_frames
	
	var center_y = anim.frame_height / 2.0
	
	sprite.offset.y = center_y - anim.ground_offset
	collision.position.y = center_y - anim.ground_offset - 4
	
	var target_speed = animation_speeds.get(animation_name, 8.0)
	sprite.sprite_frames.set_animation_speed(animation_name, target_speed)
		
	play(animation_name)

func enter_idle(anim: String):
	load_animation(anim)

func enter_walk(dir: int):
	if dir == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	load_animation("Walk")

func play_sleep_sequence() -> void:
	if pokemon_data.animations["DeepBreath"] != null:
		load_animation("DeepBreath")
		sprite.sprite_frames.set_animation_loop("DeepBreath", false)
		await sprite.animation_finished 

	if pokemon_data.animations["Sleep"] != null:
		load_animation("Sleep")
	else:
		load_animation("Idle")

func play_wake_sequence() -> void:
	if pokemon_data.animations["EventSleep"] != null:
		load_animation("EventSleep")
		sprite.sprite_frames.set_animation_loop("EventSleep", false)
		await sprite.animation_finished
	
	if pokemon_data.animations["Wake"] != null:
		load_animation("Wake")
		sprite.sprite_frames.set_animation_loop("Wake", false)
		await sprite.animation_finished
		
	load_animation("Idle")

func enter_dragged() -> void:
	if pokemon_data.animations["Cringe"] != null:
		load_animation("Cringe")
	else:
		load_animation("Idle")

func play_landing_sequence() -> void:
	if pokemon_data.animations["HitGround"] != null:
		load_animation("HitGround")
		sprite.sprite_frames.set_animation_loop("HitGround", false)
		await sprite.animation_finished

func play(animation_name: String):
	sprite.play(animation_name)
