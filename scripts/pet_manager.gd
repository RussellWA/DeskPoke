extends Node

const PET_SCENE = preload("res://scenes/pet.tscn")
const MAX_PETS := 6

var pets: Array[Pet] = []

func spawn_pet(data: PokeData):
	if pets.size() >= MAX_PETS:
		return
	
	var pet = PET_SCENE.instantiate()

	pet.add_to_group("pets") 
	
	add_child(pet)
	
	pet.setup(data)
	var ground_x = DesktopController.get_ground_y()
	pet.global_position = Vector2(ground_x / 2.0, 200)

	#print("Screen size:", DisplayServer.screen_get_size())
	#print("Window size:", DisplayServer.window_get_size())
	#print("Desktop rect:", DesktopController.desktop_rect)
	#print("Viewport:", get_viewport().get_visible_rect())
	#print("Scale:", DisplayServer.screen_get_scale())
	#print("Pet Pos ", pet.position)
	
	pet.on_despawned.connect(_on_pet_despawned)

	pets.append(pet)

func get_pets() -> Array[Pet]:
	return pets

func _on_pet_despawned(despawning_pet: Pet) -> void:
	var pet = despawning_pet.pokemon_data
	
	if not pets.has(pet):
		return

	pets.erase(pet)
	pet.queue_free()
