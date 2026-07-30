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
	
	# This array will hold the points of our clickable areas
	var poly = PackedVector2Array()

	if active_pets.is_empty():
		# If there are no pets, make a tiny 1x1 pixel in the corner clickable.
		# This makes 99.9% of your screen completely passthrough to the desktop.
		poly.append(Vector2(0, 0))
		poly.append(Vector2(1, 0))
		poly.append(Vector2(1, 1))
		poly.append(Vector2(0, 1))
	else:
		var hub_point = Vector2.ZERO
		
		for i in range(active_pets.size()):
			var pet = active_pets[i]
			var shape = pet.get_node_or_null("CollisionShape2D")
			
			if shape and shape.shape is RectangleShape2D:
				# 1. Get the true bounding box size and center
				var rect_size = shape.shape.size * pet.scale
				var center_pos = pet.global_position + (shape.position * pet.scale)
				
				# 2. Calculate the 4 corners of the pet's collision box
				var top_left = center_pos - (rect_size / 2.0)
				var top_right = top_left + Vector2(rect_size.x, 0)
				var bottom_right = top_left + rect_size
				var bottom_left = top_left + Vector2(0, rect_size.y)
				
				# 3. Save the very first point of the first pet as our "Hub"
				if i == 0:
					hub_point = top_left
					
				# 4. Draw the square around the pet
				poly.append(top_left)
				poly.append(top_right)
				poly.append(bottom_right)
				poly.append(bottom_left)
				
				# 5. Close the square, and trace a zero-width line back to the Hub
				# This connects all pets into "one polygon" without blocking the desktop!
				poly.append(top_left)
				poly.append(hub_point) 

	# Send the final polygon to the Operating System
	DisplayServer.window_set_mouse_passthrough(poly)
