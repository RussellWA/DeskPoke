extends RefCounted
class_name PokemonImporter

func import_pokemon(folder_path: String) -> PokeData:
	print("folder ", folder_path)
	var pokemon := PokeData.new()

	var xml_parser := AnimXmlParser.new()
	var sprite_importer := SpriteSheetImporter.new()

	var animations = xml_parser.parse(folder_path)
	
	pokemon.name = folder_path.get_file()
	pokemon.shadow_size = 1
	
	for anim in animations:
		var sprite_path = folder_path.path_join(anim.name + "-Anim.png")
		
		var image = Image.load_from_file(sprite_path)
		
		var facing_int = get_facing(anim.name)
		
		if image != null:
			var offset = sprite_importer.calculate_ground_offset_for_row(
				image,
				anim.frame_width,
				anim.frame_height,
				facing_int
			)
			
			anim.ground_offset = offset
		
			anim.sprite_frames = sprite_importer.import_animation(
				image,
				anim,
				facing_int
			)
		
		pokemon.animations[anim.name] = anim
	
	return pokemon

func get_facing(anim_name: String) -> int:
	match anim_name:
		"Walk":
			return Direction.Facing.RIGHT
		"Run":
			return Direction.Facing.RIGHT
		"Attack":
			return Direction.Facing.RIGHT

		"Pose":
			return Direction.Facing.DOWN
		"Idle":
			return Direction.Facing.DOWN
		"Sleep":
			return Direction.Facing.DOWN
		"Hurt":
			return Direction.Facing.DOWN

		_:
			return Direction.Facing.DOWN
