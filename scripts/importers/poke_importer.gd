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
			anim
		)
		
		pokemon.animations[anim.name] = anim

	return pokemon
