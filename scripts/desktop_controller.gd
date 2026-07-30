extends Node

@onready var ui_panel: Control = $"../CanvasLayer/UIPanel"
var desktop_rect: Rect2i

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
	var active_pets = get_tree().get_nodes_in_group("pets")
	var poly = PackedVector2Array()

	var hub_point = Vector2.ZERO
	var has_hub = false

	# 1. ADD UI PANEL TO PASSTHROUGH POLYGON (So clicks work on UI buttons!)
	if ui_panel and ui_panel.visible:
		var rect = ui_panel.get_global_rect()
		var top_left = rect.position
		var top_right = top_left + Vector2(rect.size.x, 0)
		var bottom_right = top_left + rect.size
		var bottom_left = top_left + Vector2(0, rect.size.y)
		
		hub_point = top_left
		has_hub = true
		
		poly.append(top_left)
		poly.append(top_right)
		poly.append(bottom_right)
		poly.append(bottom_left)
		poly.append(top_left)

	# 2. ADD PETS TO PASSTHROUGH POLYGON (Your existing code)
	for i in range(active_pets.size()):
		var pet = active_pets[i]
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
				poly.append(top_left)
				poly.append(hub_point) # Trace back to hub

	# If nothing is on screen, fallback to 1x1 pixel
	if poly.is_empty():
		poly.append(Vector2(0, 0))
		poly.append(Vector2(1, 0))
		poly.append(Vector2(1, 1))
		poly.append(Vector2(0, 1))

	DisplayServer.window_set_mouse_passthrough(poly)
