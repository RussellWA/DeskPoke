extends Window

var active_pet: Node = null

@onready var scale_slider: HSlider = $CanvasLayer/PetPanel/VBoxContainer/ScaleSlider
@onready var despawn_btn: Button = $CanvasLayer/PetPanel/VBoxContainer/DespawnBtn
@onready var close_btn: Button = $CanvasLayer/PetPanel/VBoxContainer/CloseBtn
@onready var name_label: Label = $CanvasLayer/PetPanel/VBoxContainer/Name

func _ready() -> void:
	focus_exited.connect(hide)

# Your PetManager will call this function!
func open_for_pet(pet: Node) -> void:
	active_pet = pet
	
	name_label.text = active_pet.pokemon_data.name
	
	# 1. Update the slider to match the pet's current size without triggering the signal
	scale_slider.set_value_no_signal(active_pet.scale.x)
	
	# 2. Move the window right next to the mouse cursor!
	var mouse_pos = DisplayServer.mouse_get_position()
	position = mouse_pos + Vector2i(0, -200) 
	
	# 3. Show the menu and force the OS to focus on it
	show()
	grab_focus()

func _on_despawn_btn_pressed() -> void:
	if active_pet and is_instance_valid(active_pet):
		active_pet.despawn()
	hide()

func _on_scale_slider_value_changed(value: float) -> void:
	if active_pet and is_instance_valid(active_pet):
		# Apply the scale evenly to both X and Y
		active_pet.scale = Vector2(value, value)

func _on_close_btn_pressed() -> void:
	hide()
