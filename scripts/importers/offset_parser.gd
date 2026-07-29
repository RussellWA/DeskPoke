extends RefCounted
class_name OffsetParser

func parse(
	offset_path: String,
	frame_width: int,
	frame_height: int
) -> Array[FrameOffset]:
	var offsets: Array[FrameOffset] = []
	
	var image := Image.new()

	var err = image.load(offset_path)

	if err != OK:
		push_error("Couldn't load offset image.")
		return []
	
	var columns = image.get_width() / frame_width
	var rows = image.get_height() / frame_height
	
	for row in range(rows):
		for column in range(columns):

			var frame_rect = Rect2i(
				column * frame_width,
				row * frame_height,
				frame_width,
				frame_height
			)

			var frame = inspect_frame(image, frame_rect)
			offsets.append(frame)
	
	return offsets

func inspect_frame(image: Image, frame_rect: Rect2i) -> FrameOffset:
	var offset := FrameOffset.new()
	
	for y in range(frame_rect.size.y):
		for x in range(frame_rect.size.x):

			var pixel_x = frame_rect.position.x + x
			var pixel_y = frame_rect.position.y + y

			var color = image.get_pixel(pixel_x, pixel_y)

			if color.a == 0:
				continue

			if color == Color.GREEN:
				offset.body = Vector2i(x, y)

			elif color == Color.BLACK:
				offset.head = Vector2i(x, y)

			elif color == Color.RED:
				offset.left_hand = Vector2i(x, y)

			elif color == Color.BLUE:
				offset.right_hand = Vector2i(x, y)
	
	return offset
