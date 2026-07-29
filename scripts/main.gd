extends Node2D

func _ready():

	var importer := PokemonImporter.new()

	var mudkip = importer.import_pokemon("res://assets/mudkip")

	$PetManager.spawn_pet(mudkip)
