extends CharacterBody2D

class_name Pet

var window_size: Vector2i

var pokemon_data: PokeData

@onready var movement_controller = $MovementController
@onready var animation_controller = $AnimationController

@export var pet_scale := 2.0

func _ready() -> void:
	window_size = get_window().size
	scale = Vector2.ONE * pet_scale
	
	get_viewport().transparent_bg = true

func setup(data: PokeData):
	pokemon_data = data
	
	print("anims: ", pokemon_data.animations)

	animation_controller.load_animation(
		pokemon_data,
		"Pose"
	)

func _physics_process(_delta: float) -> void:
	velocity = movement_controller.get_velocity()
	move_and_slide()

#func get_feet_offset() -> float:
	#var frame = sprite.sprite_frames.get_frame_texture("walk_right", 0)
#
	#return frame.get_height() / 2.0

func stand_on_ground():
	#position.y = DesktopController.get_ground_y() + get_feet_offset()
	position.y = DesktopController.get_ground_y()
