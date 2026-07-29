extends RefCounted
class_name PokemonImporter

func import_pokemon(folder_path: String) -> PokeData:
	var pokemon := PokeData.new()

	var xml_parser := AnimXmlParser.new()
	var offset_parser := OffsetParser.new()
	var sprite_importer := SpriteSheetImporter.new()

	var animations = xml_parser.parse(folder_path)
	
	pokemon.name = folder_path.get_file()
	pokemon.shadow_size = 1
	
	for anim in animations:
		var offset_path = folder_path.path_join(anim.name + "-Offsets.png")
		var sprite_path = folder_path.path_join(anim.name + "-Anim.png")
		
		anim.offsets = offset_parser.parse(
			offset_path,
			anim.frame_width,
			anim.frame_height
		)
		
		anim.sprite_frames = sprite_importer.import_animation(
			sprite_path,
			anim,
			get_facing(anim.name)
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
