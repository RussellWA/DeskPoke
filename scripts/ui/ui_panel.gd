extends PanelContainer

@export var pet_scene: PackedScene

var file_dialog: FileDialog
@onready var pokemon_list: ItemList = $VBoxContainer/PokeList

var imported_pokemon: Dictionary = {}

func _ready() -> void:
	DesktopController.ui_panel = self
	
	scan_for_imported_pokemon()
	
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true
	add_child(file_dialog)
	
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.zip ; Zip Files"]
	file_dialog.file_selected.connect(_on_zip_selected)

func _on_zip_selected(path: String) -> void:
	var zip_name = path.get_file().get_basename()
	var target_folder = "user://assets/" + zip_name + "/"
	
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

		var destination_path = target_folder + internal_path
		
		var base_dir = destination_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(base_dir):
			DirAccess.make_dir_recursive_absolute(base_dir)
		
		var file = FileAccess.open(destination_path, FileAccess.WRITE)
		if file:
			file.store_buffer(buffer)
			file.close()

	zip.close()
	
	scan_for_imported_pokemon()

func scan_for_imported_pokemon() -> void:
	var base_path = "user://assets/"

	if not DirAccess.dir_exists_absolute(base_path):
		DirAccess.make_dir_recursive_absolute(base_path)
		return # Nothing to load yet!

	var dir = DirAccess.open(base_path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()

		while folder_name != "":
			if dir.current_is_dir() and not folder_name.begins_with("."):
				
				var full_folder_path = base_path + folder_name + "/"
				imported_pokemon[folder_name] = full_folder_path
				
			folder_name = dir.get_next()
			
		dir.list_dir_end()

	_update_pokemon_list_ui()

func _update_pokemon_list_ui() -> void:
	pokemon_list.clear()
	for p_name in imported_pokemon.keys():
		pokemon_list.add_item(p_name)

func _on_import_zip_button_pressed() -> void:
	file_dialog.popup_centered(Vector2i(600, 400))

func _on_spawn_btn_pressed() -> void:
	var selected_indexes = pokemon_list.get_selected_items()
	
	if selected_indexes.is_empty():
		return
	
	var pokemon_name = pokemon_list.get_item_text(selected_indexes[0])
	var folder_path = imported_pokemon[pokemon_name] 

	var importer = PokemonImporter.new()
	var new_pokemon_data = importer.import_pokemon(folder_path)

	$"../../../PetManager".spawn_pet(new_pokemon_data)
		
	pokemon_list.deselect_all()

func _on_despawn_btn_pressed() -> void:
	var pets = get_tree().get_nodes_in_group("pets")
	for pet in pets:
		pet.queue_free()
	pokemon_list.deselect_all()

func _on_up_btn_pressed() -> void:
	var selected_indexes = pokemon_list.get_selected_items()
	for pet in get_tree().get_nodes_in_group("pets"):
		pet.scale += Vector2(0.2, 0.2)

func _on_down_btn_pressed() -> void:
	for pet in get_tree().get_nodes_in_group("pets"):
		if pet.scale.x > 0.4: # Prevent shrinking to zero
			pet.scale -= Vector2(0.2, 0.2)
