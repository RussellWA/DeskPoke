extends Node

var ui_panel: PanelContainer
var desktop_rect: Rect2i
var last_poly: PackedVector2Array = []

func _ready() -> void:
	var window = get_window()
	var current_screen = DisplayServer.window_get_current_screen()
	desktop_rect = DisplayServer.screen_get_usable_rect(current_screen)
	
	window.mode = Window.MODE_WINDOWED
	window.borderless = true
	window.transparent = true 
	window.transparent_bg = true
	window.always_on_top = true
	window.unfocusable = true
	

func get_left_boundary() -> float:
	return 0.0

func get_right_boundary() -> float:
	return desktop_rect.size.x

func get_ground_y() -> float:
	return desktop_rect.size.y

func _process(delta):
	if get_window().mode == Window.MODE_MINIMIZED:
		get_window().mode = Window.MODE_WINDOWED

	var poly = PackedVector2Array()
	var active_pets = get_tree().get_nodes_in_group("pets")
	
	# If there are no pets, make the passthrough a tiny 1-pixel dot so it doesn't block the screen
	if active_pets.is_empty():
		poly.append(Vector2(0, 0))
		poly.append(Vector2(1, 0))
		poly.append(Vector2(1, 1))
		poly.append(Vector2(0, 1))
		DisplayServer.window_set_mouse_passthrough(poly)
		return

	# If there ARE pets, draw the polygon just for them
	var hub_point = Vector2.ZERO
	var has_hub = false

	for pet in active_pets:
		var sprite = pet.get_node_or_null("AnimatedSprite2D")
		
		if sprite and sprite.sprite_frames:
			var texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
			
			if texture:
				var tex_size = texture.get_size()
				var offset = sprite.offset
				
				if sprite.centered:
					offset -= tex_size / 2.0
					
				var top_left = sprite.global_position + (offset * sprite.global_scale)
				var rect_size = tex_size * sprite.global_scale
				
				var top_right = top_left + Vector2(rect_size.x, 0)
				var bottom_right = top_left + rect_size
				var bottom_left = top_left + Vector2(0, rect_size.y)
				
				if not has_hub:
					hub_point = top_left
					has_hub = true
				
				poly.append(top_left)
				poly.append(top_right)
				poly.append(bottom_right)
				poly.append(bottom_left)
				
				# Close the square, and trace a zero-width line back to the Hub
				poly.append(top_left)
				poly.append(hub_point)

	# Clean the array to prevent Windows crashes
	var clean_poly = PackedVector2Array()
	for pt in poly:
		if clean_poly.is_empty() or clean_poly[clean_poly.size() - 1] != pt:
			clean_poly.append(pt)

	DisplayServer.window_set_mouse_passthrough(clean_poly)
