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

func _process(delta: float) -> void:
	# ANTI-MINIMIZE FORCEFIELD
	if get_window().mode == Window.MODE_MINIMIZED:
		get_window().mode = Window.MODE_WINDOWED
		
	# 1. GATHER ALL RECTANGLES (Pets + UI)
	var rects: Array[Rect2] = []
	
	# -> ADD YOUR UI PANEL RECTANGLE HERE! 
	# Example: rects.append(ui_panel.get_global_rect())
	
	var active_pets = get_tree().get_nodes_in_group("pets")
	for pet in active_pets:
		var sprite = pet.get_node_or_null("AnimatedSprite2D")
		if sprite and sprite.sprite_frames:
			var tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
			if tex:
				var padding = Vector2(10, 10)
				var tex_size = tex.get_size() * sprite.global_scale
				var offset = sprite.offset * sprite.global_scale
				
				if sprite.centered:
					offset -= tex_size / 2.0
					
				var top_left = (sprite.global_position + offset - padding).round()
				var total_size = (tex_size + (padding * 2.0)).round()
				
				#var top_left = (sprite.global_position + offset).round()
				#var total_size = tex_size.round()
				
				rects.append(Rect2(top_left, total_size))

	# 2. MERGE OVERLAPPING RECTANGLES
	# If two pets walk past each other, this merges them into one big box so lines never cross!
	var finished_merging = false
	while not finished_merging:
		finished_merging = true
		for i in range(rects.size()):
			for j in range(i + 1, rects.size()):
				if rects[i].intersects(rects[j]):
					var merged_rect = rects[i].merge(rects[j])
					rects.remove_at(j)
					rects.remove_at(i)
					rects.append(merged_rect)
					finished_merging = false
					break
			if not finished_merging:
				break

	# 3. SORT FROM LEFT TO RIGHT
	# We must process the boxes from left to right so the comb teeth never double-back.
	rects.sort_custom(func(a, b): return a.position.x < b.position.x)

	# 4. BUILD THE "COMB" POLYGON
	var poly = PackedVector2Array()
	poly.append(Vector2(0, 0)) # Start at top-left of monitor
	
	for r in rects:
		var tl = r.position
		var tr = tl + Vector2(r.size.x, 0)
		var br = tl + r.size
		var bl = tl + Vector2(0, r.size.y)
		
		var drop_point = Vector2(tl.x, 0)
		
		# Trace along the top edge, drop down, trace the box, and go straight back up
		poly.append(drop_point)
		poly.append(tl)
		poly.append(tr)
		poly.append(br)
		poly.append(bl)
		poly.append(tl)
		poly.append(drop_point)
		
	# Close the polygon at the top-right of the monitor
	var current_screen = DisplayServer.window_get_current_screen()
	var screen_width = DisplayServer.screen_get_usable_rect(current_screen).size.x
	poly.append(Vector2(screen_width, 0))
	poly.append(Vector2(0, 0))
	
	# Apply to OS
	DisplayServer.window_set_mouse_passthrough(poly)
