extends Node

const PET_SCENE = preload("res://scenes/pet.tscn")
const MAX_PETS := 6

var pets: Array[Pet] = []

@export var inspector_window: Window

func spawn_pet(data: PokeData):
	if pets.size() >= MAX_PETS:
		return
	
	var pet = PET_SCENE.instantiate()

	pet.add_to_group("pets") 
	
	add_child(pet)
	
	pet.setup(data)
	var ground_x = DesktopController.get_ground_x()
	var ground_y = DesktopController.get_ground_y()
	pet.global_position = Vector2(ground_x / 2.0, ground_y)
	pet.spawn_sequence(Vector2(ground_x / 2.0, ground_y))
	
	pet.on_right_clicked.connect(inspector_window.open_for_pet)

	pets.append(pet)

func get_pets() -> Array[Pet]:
	return pets

func _on_ui_panel_recall_pets() -> void:
	var all_pets = get_tree().get_nodes_in_group("pets")
	for pet in all_pets:
		pet.despawn()
		pets.erase(pet)
		pet.queue_free()
	
