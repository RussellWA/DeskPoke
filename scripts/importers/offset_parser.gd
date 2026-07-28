extends RefCounted
class_name OffsetParser

#func parse(offset_path: String) -> Array:
	#var image := Image.new()
#
	#var err = image.load(offset_path)
#
	#if err != OK:
		#push_error("Couldn't load offset image.")
		#return []

func inspect_frame(image: Image, frame_rect: Rect2i):
	for y in frame_rect.size.y:
		for x in frame_rect.size.x:
			var color = image.get_pixel(x,y)
			print("color: ", color, " | pos: ", x, ",", y)
