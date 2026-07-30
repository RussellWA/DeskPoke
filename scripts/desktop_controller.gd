extends Node

var desktop_rect: Rect2i

func _ready() -> void:
	var current_screen = DisplayServer.window_get_current_screen()
	desktop_rect = DisplayServer.screen_get_usable_rect(current_screen)
	get_window().position = desktop_rect.position
	get_window().size = desktop_rect.size
	get_window().transparent = true 
	get_window().transparent_bg = true
	
func get_left_boundary() -> float:
	return desktop_rect.position.x

func get_right_boundary() -> float:
	return desktop_rect.position.x + desktop_rect.size.x

func get_ground_y() -> float:
	return desktop_rect.size.y

func _process(delta):
	var active_pets = get_tree().get_nodes_in_group("pets")
	
	# 1. Get the global OS mouse position and convert it to local window coordinates
	var os_mouse_pos = DisplayServer.mouse_get_position()
	var window_pos = get_window().position
	var local_mouse_pos = Vector2(os_mouse_pos - window_pos)
	
	var is_hovering_pet = false
	
	# 2. Check if the mouse is hovering over ANY pet's collision area
	for pet in active_pets:
		var shape = pet.get_node_or_null("CollisionShape2D")
		
		if shape and shape.shape is RectangleShape2D:
			# Calculate the pet's true bounding box on screen, factoring in the scale
			var rect_size = shape.shape.size * pet.scale
			
			# Use the collision box offset (-20) that we set up earlier!
			var center_pos = pet.global_position + (shape.position * pet.scale)
			var pet_rect = Rect2(center_pos - (rect_size / 2.0), rect_size)
			
			# If the OS mouse is inside this box, we are hovering a pet
			if pet_rect.has_point(local_mouse_pos):
				is_hovering_pet = true
				break # Stop checking, we found one!
				
	# 3. Toggle the window's passthrough state based on our check
	var should_passthrough = not is_hovering_pet
	
	# Only update the window if the state actually changed (saves performance)
	if get_window().mouse_passthrough != should_passthrough:
		get_window().mouse_passthrough = should_passthrough
