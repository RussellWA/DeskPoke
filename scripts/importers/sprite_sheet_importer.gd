extends RefCounted
class_name SpriteSheetImporter

func import_animation(
	image_path: String,
	anim: AnimationData,
	row: Direction.Facing
) -> SpriteFrames:
	var texture = load(image_path)

	if texture == null:
		push_error("Couldn't load sprite sheet.")
		return null
	
	var sprite_frames := SpriteFrames.new()
	sprite_frames.add_animation(anim.name)
	
	var image_width = texture.get_width()
	var image_height = texture.get_height()

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
