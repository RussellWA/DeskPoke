extends Node

var ui_panel: PanelContainer
var desktop_rect: Rect2i
var last_poly: PackedVector2Array = []

func _ready() -> void:
	var current_screen = DisplayServer.window_get_current_screen()
	desktop_rect = DisplayServer.screen_get_usable_rect(current_screen)
	get_window().position = desktop_rect.position
	get_window().size = desktop_rect.size
	get_window().transparent = true 
	get_window().transparent_bg = true
	

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
		var coll = pet.get_node_or_null("CollisionShape2D")
		if coll and coll.shape is RectangleShape2D:
			var rect_size = coll.shape.size * pet.global_scale
			var center_pos = coll.global_position
			
			var tl = (center_pos - (rect_size / 2.0)).round()
			var tr = (tl + Vector2(rect_size.x, 0)).round()
			var br = (tl + rect_size).round()
			var bl = (tl + Vector2(0, rect_size.y)).round()
			
			if not has_hub:
				hub_point = tl
				has_hub = true
				
			poly.append(tl)
			poly.append(tr)
			poly.append(br)
			poly.append(bl)
			poly.append(tl)
			poly.append(hub_point) # Trace back to hub so multiple pets connect!

	# Clean the array to prevent Windows crashes
	var clean_poly = PackedVector2Array()
	for pt in poly:
		if clean_poly.is_empty() or clean_poly[clean_poly.size() - 1] != pt:
			clean_poly.append(pt)

	DisplayServer.window_set_mouse_passthrough(clean_poly)
