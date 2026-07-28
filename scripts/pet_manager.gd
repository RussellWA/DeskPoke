extends Node

const PET_SCENE = preload("res://scenes/pet.tscn")
const MAX_PETS := 6

var pets: Array[Pet] = []

func spawn_pet():
	if pets.size() >= MAX_PETS:
		print("Maximum pets reached.")
		return
	
	var pet = PET_SCENE.instantiate()

	add_child(pet)
	
	pet.position.x = DesktopController.desktop_rect.size.x / 2.0
	pet.stand_on_ground()
	
	print("Pet pos: ", pet.position)

	pets.append(pet)

func despawn_pet(pet: Pet) -> void:
	if not pets.has(pet):
		return

	pets.erase(pet)
	pet.queue_free()
