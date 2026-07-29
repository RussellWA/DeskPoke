extends RefCounted
class_name AnimXmlParser

func parse(xml_path: String) -> Array[AnimationData]:
	var parser := XMLParser.new()

	if parser.open(xml_path+"/AnimData.xml") != OK:
		push_error("Failed to open XML.")
		return []

	var animations: Array[AnimationData] = []

	var current_animation: AnimationData = null
	var current_tag := ""
	
	print(parser.read() == OK)

	while parser.read() == OK:

		match parser.get_node_type():

			XMLParser.NODE_ELEMENT:
				current_tag = parser.get_node_name()

				if current_tag == "Anim":
					current_animation = AnimationData.new()

			XMLParser.NODE_TEXT:
				var text = parser.get_node_data().strip_edges()

				if text.is_empty():
					continue

				if current_animation == null:
					continue

				match current_tag:
					"Name":
						current_animation.name = text

					#"Index":
						#current_animation.index = int(text)

					"FrameWidth":
						current_animation.frame_width = int(text)

					"FrameHeight":
						current_animation.frame_height = int(text)

					"Duration":
						current_animation.durations.append(int(text))

			XMLParser.NODE_ELEMENT_END:

				if parser.get_node_name() == "Anim":
					animations.append(current_animation)

	return animations
