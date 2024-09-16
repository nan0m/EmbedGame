@tool
extends Control

var undo_redo #set by plugin

var transform_clipboard: Transform3D
var node_transf_clipboard: Node3D

func get_selected_nodes() -> Array[Node]:
	return EditorInterface.get_selection().get_selected_nodes()
func _ready():
	undo_redo = EditorPlugin.new().get_undo_redo()
	self.theme.set("Button/font_sizes/font_size", 14 / 160 * DisplayServer.screen_get_dpi())

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func _on_ExtractMeshFileDialog_file_selected(path):
	var selected = get_selected_nodes()[0]
	if selected is MeshInstance3D:
		var mesh = selected.get_mesh()
		var e = ResourceSaver.save(path, mesh)

func _on_PerformanceMode_toggled(button_pressed):
	var scene_root = get_tree().get_edited_scene_root()
	var nodes_in_scene = get_all_children(scene_root)

	for node in nodes_in_scene:
		if node.editor_description.find('#performance_toggle') != -1:
			if node.get('visible') != null:
				node.set_visible(not button_pressed)


func _on_toggle_virtual_cameras_toggled(button_pressed: bool) -> void:
	var scene_root = get_tree().get_edited_scene_root()
	for i in scene_root.get_tree().get_nodes_in_group("CameraDebug"):
		i.visible = button_pressed


func _on_toggle_audio_debug_toggled(button_pressed):
	var scene_root = get_tree().get_edited_scene_root()
	for i in scene_root.get_tree().get_nodes_in_group("AudioFieldDebug"):
		i.visible = button_pressed
	pass 


func _on_toggle_wind_debug_toggled(button_pressed):
	var scene_root = get_tree().get_edited_scene_root()
	for i in scene_root.get_tree().get_nodes_in_group("wind_debug"):
		i.visible = button_pressed
#	pass 
var tower


	
func _on_node_to_top_pressed():
	for i in get_selected_nodes().size():
		var node = get_selected_nodes()[i]
		node.get_parent().move_child(node, 0)

func _on_node_to_bottom_pressed():
	for i in get_selected_nodes().size():
		var node = get_selected_nodes()[i]
		node.get_parent().move_child(node, -1)
	pass 


func _on_h_terrain_pressed():
	var n = EditorInterface.get_edited_scene_root().get_tree().get_nodes_in_group("hterrain")[0]
	if n:
			var eds = EditorInterface.get_selection()
			eds.clear()
			eds.add_node(n)
	pass 


func _on_gardener_pressed():
	var n = EditorInterface.get_edited_scene_root().get_tree().get_nodes_in_group("gardener")[0]
	if n:
			var eds = EditorInterface.get_selection()
			eds.clear()
			eds.add_node(n)
	for i in EditorInterface.get_edited_scene_root().get_children():
		if i.name == "Gardener":
			var eds = EditorInterface.get_selection()
			eds.clear()
			eds.add_node(i)
	pass 


func _on_button_toggled(button_pressed: bool) -> void:
	var is_on_top:bool = ProjectSettings.get_setting("display/window/size/always_on_top", false)
	ProjectSettings.set_setting("display/window/size/always_on_top", not is_on_top)
	pass 


func _on_player_pressed() -> void:
	var n = EditorInterface.get_edited_scene_root().get_tree().get_nodes_in_group("player")[0]
	if n:
			var eds = EditorInterface.get_selection()
			eds.clear()
			eds.add_node(n)


func _on_update_editor_collider_pressed() -> void:
	var n = EditorInterface.get_edited_scene_root().get_tree().get_nodes_in_group("hterrain")[0]
	if n:
		n.update_collider()
	pass 


func _on_reset_all_pressed() -> void:
	for i in get_selected_nodes():
		var node = i
		var previous_transform = i.transform

		undo_redo.create_action("Scale the Node")
		undo_redo.add_do_method(node, "set_transform", Transform3D.IDENTITY)
		undo_redo.add_undo_method(node, "set_transform", previous_transform)
		undo_redo.commit_action()

		
	pass 

func _on_reset_scale_pressed() -> void:
	for i in get_selected_nodes():
		var node = i
		var previous_scale = i.scale

		undo_redo.create_action("Scale the Node")
		undo_redo.add_do_method(node, "set_scale", Vector3(1,1,1))
		undo_redo.add_undo_method(node, "set_scale", previous_scale)
		undo_redo.commit_action()

		
	pass 


func _on_reset_position_pressed() -> void:
	for i in get_selected_nodes():
		undo_redo.create_action(str(i.name) + "reset position")
		undo_redo.add_undo_method(i, "set_position", i.position)
		undo_redo.add_do_method(i, "set_position", Vector3(0,0,0))
		undo_redo.commit_action()

	pass 


func _on_reset_rotation_pressed() -> void:
	for i in get_selected_nodes():
		undo_redo.create_action(str(i.name) + "reset rotation")
		undo_redo.add_undo_method(i, "set_rotation", i.rotation)
		undo_redo.add_do_method(i, "set_rotation", Vector3(0,0,0))
		undo_redo.commit_action()
	pass 


func _on_button_pressed() -> void:

	var viewp:Viewport = EditorInterface.get_edited_scene_root()
	var tex: Texture = viewp.get_texture()
	var img:Image = tex.get_image()
	var time: String = Time.get_time_string_from_system().replace(":","_")

	var e =img.save_png("res://assets/art_ref/promo/screenshots/" + time + ".png" )
	pass 


func _on_reload_current_scene_pressed() -> void:
	var tscn_file_path = EditorInterface.get_edited_scene_root().scene_file_path
	if tscn_file_path != "":
		EditorInterface.reload_scene_from_path(tscn_file_path)
		pass
	pass 


func _on_transform_copy_pressed() -> void: #grab node
	var ed: Node3D = EditorInterface.get_selection().get_selected_nodes()[0]
	if ed:
		node_transf_clipboard = ed


func _on_transform_paste_pressed() -> void: #place it here
	
	var ed: Node3D = EditorInterface.get_selection().get_selected_nodes()[0]
	if EditorInterface.get_selection().get_selected_nodes()[0]:
		node_transf_clipboard.global_transform = ed.global_transform

func _on_editor_cam_45_angle_pressed() -> void:
	var cam :Camera3D = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	cam.rotation.x = -PI/4.


func _on_scan_file_changes_pressed() -> void:
	EditorInterface.get_file_system_dock().scan()
