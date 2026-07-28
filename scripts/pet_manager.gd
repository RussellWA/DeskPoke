extends Node

const PET_SCENE = preload("res://scenes/pet.tscn")
const MAX_PETS := 6

var pets: Array[Pet] = []

func spawn_pet():
	if pets.size() >= MAX_PETS:
		print("Maximum pets reached.")
		return
	
	var pet = PET_SCENE.instantiate()

	pet.position = Vector2(
		DesktopController.desktop_rect.size.x / 2.0,
		DesktopController.get_ground_y()
	)
	
	print("Pet pos: ", pet.position)

	add_child(pet)
	pets.append(pet)

func despawn_pet(pet: Pet) -> void:
	if not pets.has(pet):
		return

	pets.erase(pet)
	pet.queue_free()
