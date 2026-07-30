extends PanelContainer

@export var pet_scene: PackedScene # Assign your Pet.tscn here in Inspector

var file_dialog: FileDialog
@onready var pokemon_list: ItemList = $CanvasLayer/UIPanel/VBoxContainer/ItemList

var imported_pokemon: Dictionary = {}

func _ready() -> void:
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true
	add_child(file_dialog)
	
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.zip ; Zip Files"]
	file_dialog.file_selected.connect(_on_zip_selected)

# --- ZIP IMPORT SYSTEM ---
func _on_zip_selected(path: String) -> void:
	var zip_name = path.get_file().get_basename()
	var target_folder = "res://assets/" + zip_name + "/"
	
	var dir_err = DirAccess.make_dir_recursive_absolute(target_folder)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		print("Failed to create folder: ", target_folder)
		return
	
	var zip = ZIPReader.new()
	var err = zip.open(path)
	if err != OK:
		print("Failed to open ZIP file.")
		return

	var files = zip.get_files()
	for internal_path in files:
		# Skip directory entries inside the zip
		if internal_path.ends_with("/"):
			continue
			
		# Read raw byte buffer from ZIP
		var buffer = zip.read_file(internal_path)
		
		# Get the clean file name (e.g., "idle_01.png")
		var destination_path = target_folder + internal_path
		
		# Save the file to disk inside res://assets/<zip_name>/
		var file = FileAccess.open(destination_path, FileAccess.WRITE)
		if file:
			file.store_buffer(buffer)
			file.close()
			print("Extracted: ", destination_path)

	zip.close()
	# Refresh UI List
	#_update_pokemon_list_ui()
	#print("Successfully imported: ", pokemon_name)

func _update_pokemon_list_ui() -> void:
	pokemon_list.clear()
	for p_name in imported_pokemon.keys():
		pokemon_list.add_item(p_name)

func _on_import_zip_button_pressed() -> void:
	print("this")
	file_dialog.popup_centered(Vector2i(600, 400))

func _on_spawn_btn_pressed() -> void:
	var selected_indexes = pokemon_list.get_selected_items()
	if selected_indexes.is_empty():
		return
		
	var pokemon_name = pokemon_list.get_item_text(selected_indexes[0])
	var frames = imported_pokemon[pokemon_name]

	# Instantiate pet
	var new_pet = pet_scene.instantiate()
	new_pet.add_to_group("pets")
	
	# Middle of usable desktop space
	new_pet.global_position = Vector2(960, 540) 
	
	add_child(new_pet)

	# Set the animated sprite frames
	var anim_sprite = new_pet.get_node("AnimatedSprite2D")
	anim_sprite.sprite_frames = frames
	anim_sprite.play("default")

func _on_despawn_btn_pressed() -> void:
	var pets = get_tree().get_nodes_in_group("pets")
	if not pets.is_empty():
		# Despawn the last spawned pet
		pets[-1].queue_free()

func _on_up_btn_pressed() -> void:
	var selected_indexes = pokemon_list.get_selected_items()
	for pet in get_tree().get_nodes_in_group("pets"):
		pet.scale += Vector2(0.2, 0.2)

func _on_down_btn_pressed() -> void:
	for pet in get_tree().get_nodes_in_group("pets"):
		if pet.scale.x > 0.4: # Prevent shrinking to zero
			pet.scale -= Vector2(0.2, 0.2)
