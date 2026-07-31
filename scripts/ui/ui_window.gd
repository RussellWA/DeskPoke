extends Window

enum Corner { BOTTOM_RIGHT, BOTTOM_LEFT, TOP_LEFT, TOP_RIGHT }
var current_corner: int = Corner.BOTTOM_RIGHT

func _ready() -> void:
	snap_to_corner(current_corner)

func snap_to_corner(corner: int) -> void:
	# Because this script is inside the UIWindow, get_window() gets the UI window!
	var window = get_window() 
	
	var current_screen = DisplayServer.window_get_current_screen()
	var screen_rect = DisplayServer.screen_get_usable_rect(current_screen)
	var win_size = window.size
	
	var new_pos = Vector2i()
	
	match corner:
		Corner.TOP_LEFT:
			new_pos.x = screen_rect.position.x
			new_pos.y = screen_rect.position.y
			print("new pos: ", new_pos)
		Corner.TOP_RIGHT:
			new_pos.x = screen_rect.position.x + screen_rect.size.x - win_size.x
			new_pos.y = screen_rect.position.y
			print("new pos: ", new_pos)
		Corner.BOTTOM_LEFT:
			new_pos.x = screen_rect.position.x
			new_pos.y = screen_rect.position.y + screen_rect.size.y - win_size.y
			print("new pos: ", new_pos)
		Corner.BOTTOM_RIGHT:
			new_pos.x = screen_rect.position.x + screen_rect.size.x - win_size.x
			new_pos.y = screen_rect.position.y + screen_rect.size.y - win_size.y
			print("new pos: ", new_pos)
			
	window.position = new_pos
	
var is_menu_open: bool = true
var full_menu_size: Vector2i = Vector2i(300, 400)
var collapsed_size: Vector2i = Vector2i(64, 64) # Make this the size of your small logo button

func toggle_menu(open: bool) -> void:
	is_menu_open = open
	var window = get_window()
	
	if is_menu_open:
		$OpenBtn.hide()
		$CanvasLayer/UIPanel.show()
		window.size = full_menu_size
	else:
		$CanvasLayer/UIPanel.hide()
		$OpenBtn.show()
		window.size = collapsed_size

	snap_to_corner(current_corner)

func _on_open_btn_pressed() -> void:
	toggle_menu(true)

func _on_close_btn_pressed() -> void:
	toggle_menu(false)


func _on_snap_btn_pressed() -> void:
	current_corner = (current_corner + 1) % 4 
	snap_to_corner(current_corner)
