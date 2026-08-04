extends RefCounted
class_name SpriteSheetImporter

func import_animation(
	image: Image,
	anim: AnimationData,
	row: Direction.Facing
) -> SpriteFrames:
	var texture = ImageTexture.create_from_image(image)
	
	if texture == null:
		print("Could not get texture from image")
	
	var sprite_frames := SpriteFrames.new()
	sprite_frames.add_animation(anim.name)
	
	var image_width = texture.get_width()
	#var image_height = texture.get_height()

	var columns = image_width / anim.frame_width
	
	for column in range(columns):
		var region := Rect2(
			column * anim.frame_width,
			row * anim.frame_height,
			anim.frame_width,
			anim.frame_height
		)
		
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = region
		
		sprite_frames.add_frame(
			anim.name,
			atlas
		)
	
	return sprite_frames

func calculate_ground_offset_for_row(
	image: Image,
	_frame_width: int,
	frame_height: int,
	row_index: int
) -> int:
	var start_y = row_index * frame_height
	var full_image_width = image.get_width()
	
	# Scan from the bottom of this specific 40px cell upwards
	for local_y in range(frame_height - 1, -1, -1):
		var global_y = start_y + local_y
		
		# TRAP 1 FIXED: Scan across the ENTIRE row width, not just one frame!
		for x in range(full_image_width):
			var color = image.get_pixel(x, global_y)
			
			# TRAP 2 FIXED: Ignore almost invisible artifact pixels
			if color.a > 0.1: 
				# Return the exact local Y coordinate (e.g., 28)
				return local_y
				
	return int(frame_height / 2.0) # Fallback to center if completely empty
