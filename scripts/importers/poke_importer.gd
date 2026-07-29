extends RefCounted
class_name PokemonImporter

func import_pokemon(xml_path: String) -> PokeData:
	var pokemon := PokeData.new()

	var xml_parser := AnimXmlParser.new()
	var offset_parser := OffsetParser.new()

	var animations = xml_parser.parse(xml_path)

	for anim in animations:

		anim.offsets = offset_parser.parse(
			"",
			anim.frame_width,
			anim.frame_height
		)

		pokemon.animations[anim.name] = anim

	return pokemon
