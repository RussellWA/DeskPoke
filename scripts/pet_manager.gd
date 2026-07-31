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
	pet.position.x = DesktopController.desktop_rect.size.x / 2.0
	pet.position.y = DesktopController.get_ground_y()
	
	pet.on_despawned.connect(_on_pet_despawned)

	pets.append(pet)

func recall_pet(pet: Pet) -> void:
	if not pets.has(pet):
		return

	pets.erase(pet)
	pet.queue_free()

func get_pets() -> Array[Pet]:
	return pets

func _on_pet_despawned(despawning_pet: Pet) -> void:
	# You now have full access to the exact pet that is despawning!
	var data = despawning_pet.pokemon_data
	
	print("PetManager noticed a pet is despawning!")
	# print("It was: ", data.pokemon_name) # (If your PokeData has a name variable)
	
	# You can now do whatever the manager needs to do with this specific data!
