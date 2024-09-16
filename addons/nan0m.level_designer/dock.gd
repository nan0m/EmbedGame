@tool
extends Control

var save_path = "res://addons/nan0m.level_designer/save_data/save_1.tres"
@onready var align_with_surface_checkbox: CheckBox = %AlignWithSurfaceCheckbox

var selected_tscn: String = "res://assets/interactables/crate/crate.tscn"
var active_button: Control 
@onready var item_tab_container: TabContainer = %ItemTabContainer
signal item_selection_changed
#region accessed by Placer Script


func is_scene_selected() -> bool:
	return selected_tscn != ""
func get_selected_scene() -> String:
	return selected_tscn
func clear_selected_scene():
	selected_tscn = ""
	
	
#endregion
	

func _get_buttons() -> Array:
	return get_tree().get_nodes_in_group("scene_button")

func _add_tab(tab_name: String = "New Tab") -> Control:
	var new_tab = load("res://addons/nan0m.level_designer/base_tab.tscn").instantiate()
	new_tab.name = tab_name
	item_tab_container.add_child(new_tab,true)
	new_tab.set_owner(self)
	return new_tab
func load_from_save_data() -> void:
	var data = load_data()
	if not data: return
	clear_tabs()

	for tab_name in data.keys():
		var new_tab = _add_tab(tab_name)
		for dict in data[tab_name]:
			_add_button_to_tab(new_tab,dict["scene_path"], dict["texture"],dict["pinned"])
	#set_button_size_slider(data["button_size"])
	#print("button size ", data["button_size"])
	#print(data)
func _ready() -> void:
	load_from_save_data()
	
func _on_any_scene_button_pressed(button : Control):
	active_button = button
	selected_tscn = button.scene_path
	for btn in _get_buttons():
		if btn != button:
			btn.set_pressed(false)
	item_selection_changed.emit()


func buttons_clear_pressed() -> void:
		for btn in _get_buttons():
			btn.set_pressed(false)

func set_rotation_options_button_to_index(idx: int) -> void:
	var opt_btn: OptionButton= %RotationOptions
	opt_btn.select(idx)
func get_rotation_axis_from_options() -> Vector3:
	var opt_btn: OptionButton= %RotationOptions
	var id = opt_btn.get_selected_id()
	match id:
		0: return Vector3.ZERO
		1: return Vector3.RIGHT
		2: return Vector3.LEFT
		3: return Vector3.UP
		4: return Vector3.DOWN
		5: return Vector3.FORWARD
		6: return Vector3.BACK
	return Vector3.ZERO

func set_rotation_options_button_to_next_option() -> void:
	var opt_btn: OptionButton= %RotationOptions
	opt_btn.select( (opt_btn.selected + 1) % opt_btn.item_count )
func _on_add_pressed() -> void:
	var fd := EditorFileDialog.new()
	fd.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILES
	fd.set_filters(PackedStringArray(["*.tscn, *.scn, *.glb, *.blend"]))
	self.add_child(fd)
	fd.popup_centered(DisplayServer.window_get_size(0) / 2) ##FIXME MAKE dependent on screen res
	fd.files_selected.connect(Callable(self,"_on_add_files_finished"))

func _on_remove_item_pressed() -> void:
	for i in _get_buttons():
		if i.get_pressed():
			i.queue_free()
	save()

func _on_add_files_finished(paths: PackedStringArray):
	for i in range(paths.size()):
		var path: String = paths[i]
		_add_button_to_tab(_get_current_tab(),path)
	## NOTE: add_files
	pass

func _add_button_to_tab(tab: Control, file_path: String, texture: ImageTexture = null, is_pinned:bool = false) -> void:
	var item = load("res://addons/nan0m.level_designer/scene_button.tscn").instantiate()
	item.scene_path = file_path
	tab.add_item_as_child(item)

	item.set_owner(self)
	item.connect("pressed", Callable(self, "_on_any_scene_button_pressed").bind(item))
	item.connect("pin_changed", Callable(self, "save"))
	item.change_size(Vector2(%ButtonSizeSlider.value, %ButtonSizeSlider.value)  * DisplayServer.screen_get_dpi())
	item.set_pinned_state(is_pinned)
	if texture and is_pinned:
		item.set_texture(texture)
	else:
		item.generate_preview()
		
	save()

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data["type"] == "files":
		for i: String in data["files"]:
			if i.ends_with(".tscn") or i.ends_with(".glb"):
				pass
			else:
				return false
		return true
	else:
		return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	for i in data["files"]:
		_add_button_to_tab(_get_current_tab(),i)

func set_button_size_slider(value: float) -> void:
	%ButtonSizeSlider.value = value

func _get_tabs() -> Array[Node]:
	return item_tab_container.get_children()
func _get_current_tab() -> Control:
	return item_tab_container.get_child(item_tab_container.current_tab)
func _get_items_from_tab(tab_name:String):
	var tab: Control
	for t in  _get_tabs():
		if t.name == tab_name:
			tab = t
			break
	return tab.get_items() 
	
func save():
	var save_resource = ResourceLoader.load(("res://addons/nan0m.level_designer/save_data/save_1.tres"))
	
	var save_dict: Dictionary = {}
	for t in self._get_tabs():
		var key: String = t.name
		var items = _get_items_from_tab(key)
		var save_data = []
		for i in items:
			save_data.append(i.get_save_data())
		save_dict[key] = save_data

	save_resource.save_dict = save_dict
	save_resource.emit_changed()
	var e = ResourceSaver.save(save_resource, save_path,ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
	
func load_data() -> Variant:
	var res = ResourceLoader.load(save_path)
	return res.save_dict


func clear_tabs() -> void:
	for i in item_tab_container.get_children():
		i.free()
	
func _on_rename_tab_pressed() -> void:

	var cur_tab: Control = _get_current_tab()
	var p: Popup = load("res://addons/nan0m.level_designer/rename_popup.tscn").instantiate()
	self.add_child(p)
	p.set_owner(self)
	p.set_text_to(cur_tab.name)
	p.popup_centered(DisplayServer.window_get_size(0) / 4)
	p.text_submitted.connect(Callable(self, "_on_rename_confirmed"))
	await p.close_requested
	p.queue_free()
	
func _on_rename_confirmed(new_name: String):
	var cur_tab: Control = _get_current_tab()
	cur_tab.name = new_name
	save()

func _on_add_tab_pressed() -> void:
	_add_tab()
	save()
	pass


func _on_remove_tab_pressed() -> void:
	_get_current_tab().free()
	save()
	
func get_is_snap_to_floor_enabled() -> bool:
	return %SnapToFloor.button_pressed
	
func set_is_snap_to_floor_enabled(flag: bool) -> void:
	%SnapToFloor.button_pressed = flag
func get_is_add_to_scene_root_enabled() -> bool:
	return %AddToSceneRoot.button_pressed

func set_is_add_to_scene_root_enabled(flag: bool) -> void:
	%AddToSceneRoot.button_pressed = flag
func get_is_align_with_surface_pressed() -> bool:
	return %AlignWithSurfaceCheckbox.button_pressed

func set_is_align_with_surface_pressed(flag: bool) -> void:
	%AlignWithSurfaceCheckbox.button_pressed = flag

func show_warning(flag: bool):
	%Warning.visible = flag
	pass

func get_is_snap_enabled() -> bool:
	return %SnapEnabledCheckBox.button_pressed
func set_is_snap_enabled(flag: bool) -> void:
	%SnapEnabledCheckBox.button_pressed = flag
	
func get_snap_vector() -> Vector3:
	return Vector3(
		%SnapVectorX.value,
		%SnapVectorY.value,
		%SnapVectorZ.value,
	)
func _on_right_pressed() -> void:
	pass 


func _on_move_item_left_pressed() -> void:
	if active_button:
		var idx = active_button.get_index()
		active_button.get_parent().move_child(active_button, idx - 1)
		save()
	pass 


func _on_move_item_right_pressed() -> void:
	if active_button:
		var idx = active_button.get_index()
		active_button.get_parent().move_child(active_button, idx + 1)
		save()
	pass 


func _on_button_size_slider_value_changed(value: float) -> void:
	## value is in inches of all things lol
	var sz := value * DisplayServer.screen_get_dpi()
	var vec := Vector2(sz,sz)
	for i in _get_buttons():
		i.change_size(vec)
