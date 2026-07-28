extends Node

var desktop_rect: Rect2i

func _ready() -> void:
	var current_screen = DisplayServer.window_get_current_screen()
	desktop_rect = DisplayServer.screen_get_usable_rect(current_screen)
	get_window().position = desktop_rect.position
	get_window().size = desktop_rect.size
	
func get_left_boundary() -> float:
	return desktop_rect.position.x

func get_right_boundary() -> float:
	return desktop_rect.position.x + desktop_rect.size.x

func get_ground_y() -> float:
	return desktop_rect.size.y
