@tool
extends VBoxContainer

@onready var scene_name_label: Label = %SceneNameLabel
#@onready var pin_texture_check_box: Button = %PinTextureCheckBox
@onready var preview_button: Button = %PreviewButton

@export var scene_path: String = "res://assets/interactables/crate/barrel.tscn"
@export var pinned: bool = false #for saving

signal pressed
signal pin_changed
func _ready() -> void:
	scene_name_label.text = scene_path.split("/")[-1]

func set_texture(texture: ImageTexture):
	preview_button.icon = texture
func generate_preview():
	var prev = EditorInterface.get_resource_previewer()
	prev.queue_resource_preview(scene_path,self,"finished","")

func finished(path: String, preview: Texture2D,  thumbnail_preview: Texture2D,  userdata:Variant):
	preview_button.icon = preview

func set_pressed(flag: bool) -> void:
	preview_button.button_pressed = flag

func get_pressed() -> bool:
	return preview_button.button_pressed
func _on_preview_button_pressed() -> void:
	self.pressed.emit()
	pass 

func get_pinned_state() -> bool:
	return true
	#return pin_texture_check_box.button_pressed
	
func set_pinned_state(flag: bool) -> void:
	return
	#pin_texture_check_box.button_pressed = flag

func get_save_data() -> Dictionary:
	var save_data:= {}
	save_data["scene_path"] = self.scene_path
	save_data["pinned"] = get_pinned_state()
	save_data["texture"] = preview_button.icon
	return save_data

func change_size(new_size: Vector2):
	%PreviewButton.custom_minimum_size = new_size 

func _on_refresh_image_button_pressed() -> void:
	generate_preview()
	pin_changed.emit()
