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
	"Togedemaru": preload("res://scene/poke/Togedemaru.tscn"),
}

# Track hover state to prevent lag
var last_hovered_pet = null 

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
	if menu.visible:
		DisplayServer.window_set_mouse_passthrough([])
		return 

	# --- 🛠️ CUSTOMIZATION ZONE 🛠️ ---
	var pad_sides = -100.0  
	var pad_top = 15.0    
	var pad_bottom = 0.0 
	#var pad_bottom = -40.0 # Reality
	# ----------------------------------

	# 1. CREATE SEPARATE BOXES FOR EACH PET
	# We start with a list of separate polygons.
	var distinct_polygons = []
	
	for pet in current_pets:
		if not is_instance_valid(pet): continue
		
		var full_size = pet.get_current_size()
		var p_x = pet.global_position.x
		var p_y = pet.global_position.y
		
		var left_x = p_x - (full_size.x / 2.0) - pad_sides
		var right_x = p_x + (full_size.x / 2.0) + pad_sides
		var top_y = p_y - (full_size.y / 2.0) - pad_top
		var bottom_y = p_y + (full_size.y / 2.0) + pad_bottom
		
		var box = PackedVector2Array([
			Vector2(left_x, top_y),
			Vector2(right_x, top_y),
			Vector2(right_x, bottom_y),
			Vector2(left_x, bottom_y)
		])
		distinct_polygons.append(box)

	# 2. MERGE OVERLAPPING BOXES (The Fix)
	# Geometry2D handles the math so the overlapping area becomes one solid shape.
	# 2. MERGE OVERLAPPING BOXES (The Fix)
	# Geometry2D handles the math so the overlapping area becomes one solid shape.
	var merged_result = []
	
	if distinct_polygons.is_empty():
		# Safety triangle if no pets exist
		merged_result.append(PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(0,1)]))
	else:
		# Start with the first pet's box
		merged_result = [distinct_polygons[0]]
		
		# Try to merge every other pet into the result
		for i in range(1, distinct_polygons.size()):
			var new_poly = distinct_polygons[i]
			
			# We just use the helper function:
			merged_result = _union_polygons(merged_result, new_poly)

	# 3. CONVERT TO SINGLE PASSTHROUGH PATH
	# DisplayServer needs ONE path. If we have islands (Pet A far left, Pet B far right),
	# we connect them with invisible lines.
	var final_polygon = PackedVector2Array()
	
	for i in range(merged_result.size()):
		var poly = merged_result[i]
		final_polygon.append_array(poly)
		# Close the loop for this island
		final_polygon.append(poly[0])
		
		# If there is another island after this, add a connecting line
		if i < merged_result.size() - 1:
			var next_poly = merged_result[i+1]
			final_polygon.append(next_poly[0])

	DisplayServer.window_set_mouse_passthrough(final_polygon)

# --- HELPER FUNCTION FOR MATH ---
# Paste this function at the bottom of Main.gd
func _union_polygons(current_polys: Array, new_poly: PackedVector2Array) -> Array:
	var result = current_polys.duplicate()
	var poly_to_add = new_poly
	
	# Try to merge 'poly_to_add' with any existing polygon that overlaps it
	var i = 0
	while i < result.size():
		var existing = result[i]
		var merged = Geometry2D.merge_polygons(existing, poly_to_add)
		
		if merged.size() == 1:
			# They overlapped and became one! 
			# Remove the old one, and update our 'poly_to_add' to be this new bigger shape
			poly_to_add = merged[0]
			result.remove_at(i)
			# Reset loop to check if this bigger shape now overlaps others
			i = 0 
		else:
			# They didn't overlap, check the next one
			i += 1
			
	result.append(poly_to_add)
	return result

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
		# If pet is now "underground", snap them up
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
	
	# B. MONITOR SECTION
	menu.add_separator("Display Settings")
	var monitor_count = DisplayServer.get_screen_count()
	# IDs 200+ are for monitors
	for i in range(monitor_count):
		var text = "Move to Monitor " + str(i + 1)
		if i == current_screen_id:
			text += " (Current)"
			menu.add_item(text, 200 + i)
			menu.set_item_disabled(menu.get_item_count() - 1, true) 
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

func _on_menu_closed():
	pass
