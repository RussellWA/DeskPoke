extends Node2D

# --- REFERENCES ---
@onready var menu = $SummonMenu

# --- CONFIGURATION ---
var max_pets = 6
var current_pets = []
var pet_targeted_for_removal = null 

# Track which monitor we are currently on
var current_screen_id = 0 

# THE LIBRARY
var pet_library = {
	"Mudkip": preload("res://scene/poke/Mudkip.tscn"),
	"Pichu": preload("res://scene/poke/Pichu.tscn"),
	# "Pichu": preload("res://Pets/Pichu.tscn")
}

func _ready():
	get_tree().root.set_transparent_background(true)
	
	# Default to Primary Monitor on start
	current_screen_id = DisplayServer.get_primary_screen()
	setup_window_for_screen(current_screen_id)
	
	# Setup Menu Signals
	menu.id_pressed.connect(_on_menu_item_pressed)
	menu.popup_hide.connect(_on_menu_closed)

	# Spawn starter
	var floor_level = get_floor_y_for_screen(current_screen_id)
	spawn_pet("Mudkip", Vector2(500, floor_level))

func _process(_delta):
	# 1. MENU MODE (Window Solid)
	if menu.visible:
		DisplayServer.window_set_mouse_passthrough([])
		return 

	# 2. PET MODE (Window Transparent with Cutouts)
	var polygon = PackedVector2Array()
	var min_x = 99999.0; var max_x = -99999.0
	var min_y = 99999.0; var max_y = -99999.0
	var found_any_pet = false

	for pet in current_pets:
		if not is_instance_valid(pet): continue
		found_any_pet = true
		
		var size = pet.get_current_size()
		var half_w = size.x / 2.0
		var half_h = size.y / 2.0
		var visual_offset_y = pet.anim.offset.y
		
		var buffer = 10.0
		var extra_top_padding = 50.0 
		
		if pet.global_position.x - half_w < min_x: min_x = pet.global_position.x - half_w - buffer
		if pet.global_position.x + half_w > max_x: max_x = pet.global_position.x + half_w + buffer
		if pet.global_position.y - half_h + visual_offset_y < min_y: 
			min_y = pet.global_position.y - half_h + visual_offset_y - buffer - extra_top_padding
		if pet.global_position.y + half_h + visual_offset_y > max_y: 
			max_y = pet.global_position.y + half_h + visual_offset_y + buffer
	
	if found_any_pet:
		polygon.append(Vector2(min_x, min_y))
		polygon.append(Vector2(max_x, min_y))
		polygon.append(Vector2(max_x, max_y))
		polygon.append(Vector2(min_x, max_y))
		DisplayServer.window_set_mouse_passthrough(polygon)
	else:
		DisplayServer.window_set_mouse_passthrough([])

# --- MONITOR MANAGEMENT ---

func setup_window_for_screen(screen_id):
	# 1. Get the position of the monitor (e.g., 1920,0 for second screen)
	var screen_pos = DisplayServer.screen_get_position(screen_id)
	# 2. Get the FULL size (including taskbar)
	var screen_size = DisplayServer.screen_get_size(screen_id)
	
	# 3. Move Window
	get_window().mode = Window.MODE_WINDOWED # Reset mode briefly to allow moving
	get_window().position = screen_pos
	get_window().size = screen_size
	get_window().always_on_top = true
	
	# 4. Update Floor for existing pets
	var new_floor_y = get_floor_y_for_screen(screen_id)
	
	for pet in current_pets:
		pet.floor_y = new_floor_y
		# If pet is now "underground" (because new screen is shorter), snap them up
		if pet.global_position.y > new_floor_y:
			pet.global_position.y = new_floor_y - 20

func get_floor_y_for_screen(screen_id):
	# The floor is the height of the "Usable Area" (Top of Taskbar)
	return DisplayServer.screen_get_usable_rect(screen_id).size.y

# --- SPAWNING SYSTEM ---

func spawn_pet(pet_name: String, start_pos: Vector2):
	if current_pets.size() >= max_pets: return

	if pet_name in pet_library:
		var scene = pet_library[pet_name]
		var new_pet = scene.instantiate()
		new_pet.position = start_pos
		
		# Set floor based on CURRENT monitor
		new_pet.floor_y = get_floor_y_for_screen(current_screen_id)
		
		new_pet.connect("request_menu", _on_pet_request_menu)
		add_child(new_pet)
		current_pets.append(new_pet)

func remove_pet(pet_node):
	if pet_node in current_pets:
		current_pets.erase(pet_node)
		pet_node.queue_free()

# --- MENU SYSTEM ---

func _on_pet_request_menu(pet_node):
	pet_targeted_for_removal = pet_node
	menu.clear()
	
	# A. SUMMON SECTION
	menu.add_separator("Summon Friend (" + str(current_pets.size()) + "/" + str(max_pets) + ")")
	var spawn_index = 0
	for pet_name in pet_library.keys():
		menu.add_item(pet_name, spawn_index)
		if current_pets.size() >= max_pets:
			menu.set_item_disabled(spawn_index, true)
		spawn_index += 1
	
	# B. MONITOR SECTION (New!)
	menu.add_separator("Display Settings")
	var monitor_count = DisplayServer.get_screen_count()
	# IDs 200+ are for monitors
	for i in range(monitor_count):
		var text = "Move to Monitor " + str(i + 1)
		if i == current_screen_id:
			text += " (Current)"
			menu.add_item(text, 200 + i)
			menu.set_item_disabled(menu.get_item_count() - 1, true) # Disable current
		else:
			menu.add_item(text, 200 + i)

	# C. ACTIONS SECTION
	menu.add_separator("Actions")
	menu.add_item("Dismiss " + pet_node.name, 100)
	menu.add_item("Quit Game", 101)

	menu.position = Vector2(get_window().position) + get_global_mouse_position()
	menu.popup()

func _on_menu_item_pressed(id):
	# SPAWN (0-99)
	if id < 100:
		var index = menu.get_item_index(id)
		var pet_name = menu.get_item_text(index)
		spawn_pet(pet_name, get_global_mouse_position() + Vector2(50, 0))
		
	# DISMISS (100)
	elif id == 100:
		if pet_targeted_for_removal != null:
			if current_pets.size() <= 1:
				print("Cannot delete last pet")
			else:
				remove_pet(pet_targeted_for_removal)
	
	# QUIT (101)
	elif id == 101:
		get_tree().quit()
		
	# MONITOR SWITCH (200+)
	elif id >= 200:
		var target_screen = id - 200
		current_screen_id = target_screen
		setup_window_for_screen(target_screen)

# Add this to the bottom of Main.gd
func _on_menu_closed():
	# This function triggers when the menu closes.
	# We don't need special logic here because _process() automatically 
	# switches back to "Transparent Mode" when menu.visible becomes false.
	pass
