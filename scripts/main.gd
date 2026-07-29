extends Node2D

func _ready():

	var importer := PokemonImporter.new()
	var mudkip = importer.import_pokemon("res://assets/mudkip")
	
	print("Mode: ", get_window().mode)
	print("Borderless: ", get_window().borderless)
	print("Position: ", get_window().position)
	print("Size: ", get_window().size)

	$PetManager.spawn_pet(mudkip)
