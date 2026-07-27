extends Node

@onready var pet = get_parent()
@onready var movement_controller = $"../MovementController"
@onready var animation_controller = $"../AnimationController"

@onready var timer: Timer = $Timer 

enum State {
	IDLE,
	WALKING,
	SLEEPING,
	DRAGGED
}

var state: State

func _ready() -> void:
	enter_walking()

func _on_timer_timeout():
	match state:
		State.IDLE:
			enter_walking()
		State.WALKING:
			enter_idle()

func enter_idle() -> void:
	state = State.IDLE
	movement_controller.stop()
	animation_controller.enter_idle()
	timer.start(2)

func enter_walking() -> void:
	state = State.WALKING
	var direction = movement_controller.get_direction()
	animation_controller.enter_walk(direction)
	movement_controller.walk(direction)
	timer.start(3)

func _on_movement_controller_hit_left() -> void:
	movement_controller.walk(1)

func _on_movement_controller_hit_right() -> void:
	movement_controller.walk(-1)
