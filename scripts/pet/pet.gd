extends CharacterBody2D

class_name Pet

var window_size: Vector2i

var pokemon_data: PokeData

@onready var movement_controller = $MovementController
@onready var animation_controller = $AnimationController
@onready var behavior_controller = $BehaviorController

@export var pet_scale := 2.0

func _ready() -> void:
	window_size = get_window().size
	scale = Vector2.ONE * pet_scale
	
	get_viewport().transparent_bg = true

func setup(data: PokeData):
	pokemon_data = data
	animation_controller.setup(data)
	behavior_controller.start(data)

func _physics_process(_delta: float) -> void:
	velocity = movement_controller.get_velocity()
	move_and_slide()
