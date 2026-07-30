extends Node

const PET_SCENE = preload("res://scenes/pet.tscn")
const MAX_PETS := 6

var pets: Array[Pet] = []

func spawn_pet(data: PokeData):
	if pets.size() >= MAX_PETS:
		print("Maximum pets reached.")
		return
	
	var pet = PET_SCENE.instantiate()
	
	add_child(pet)
	
	pet.setup(data)
	
	pet.position.x = DesktopController.desktop_rect.size.x / 2.0
	pet.position.y = DesktopController.get_ground_y()
	
	print("pet pos ", pet.position)
	
	print()

	pets.append(pet)

func despawn_pet(pet: Pet) -> void:
	if not pets.has(pet):
		return

	pets.erase(pet)
	pet.queue_free()
