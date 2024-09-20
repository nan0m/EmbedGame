@tool
extends EditorPlugin

var dock
var test_flag = true
var queue_drop = false
var cur_obj: Node3D
var was_visible_on_last_3D_screen: bool = false
func _enter_tree():
	dock = preload("res://addons/nan0m.level_designer/dock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Level Designer")
	dock.item_selection_changed.connect(Callable(self, "_on_item_selection_changed"))
	main_screen_changed.connect(Callable(self, "_on_main_screen_changed"))
	EditorInterface.edit_node(EditorInterface.get_edited_scene_root()) #makes forward gui input run bc node is selected for it to run

func _exit_tree():
	dock.save()
	remove_control_from_bottom_panel(dock)
	dock.free()

 ## needed for forward gui input to be called
func _handles(object: Object) -> bool:
	if object is Node:
		return true 
	return false
	
func _on_main_screen_changed(screen: String):
	if screen != "3D" and dock.visible:
		hide_bottom_panel()
		was_visible_on_last_3D_screen = true
	elif screen == "3D" and was_visible_on_last_3D_screen:
		make_bottom_panel_item_visible(dock)
		

func _physics_process(delta: float) -> void:
	if cur_obj:
		cur_obj.rotation = Vector3.ZERO
			
		## ensure that some node in the scene is selected else 3d forward input won't be called
		var coll_data:= _get_collision_data()
		if not coll_data:
			return
		var position = coll_data["position"]
		if dock.get_is_snap_enabled():
			position += Vector3(0.001 * Vector3.ONE)
			position = position.snapped(dock.get_snap_vector())
		cur_obj.global_position = position
		
		if dock.get_is_align_with_surface_pressed():
			var up_vector := Vector3.UP
			var normal: Vector3 = coll_data["normal"]
			var pos: Vector3 = coll_data["position"]
			if normal.dot(up_vector) < 0.999: #if not aligned perfectly
				
				cur_obj.rotation = Vector3.ZERO
				var target_dir: Vector3 = (pos +normal).normalized()
				if not pos.normalized().dot( target_dir) == 1:
					cur_obj.look_at_from_position( pos, pos - normal,up_vector)

					#cur_obj.rotate_object_local(Vector3.RIGHT, PI/2)
	
		#else:
			#cur_obj.rotation = Vector3.ZERO

		
		if dock.get_is_snap_to_floor_enabled():
			var init_pos: Vector3 = coll_data["position"]

			var found_valid_shape := false
			var aabb := AABB()
			var children :Array= get_all_children(cur_obj)
			var cs : Array = get_nodes_of_type(children, CollisionShape3D)
			var vs :Array = get_nodes_of_type(children, VisualInstance3D)
			if cs.size() > 0:
				for i in cs.size():
					var shape: Shape3D = cs[i].get_shape()
					if shape: found_valid_shape = true
					else: continue
					
					if i == 0:
						aabb = shape.get_debug_mesh().get_aabb()
					else:
						aabb.merge( shape.get_debug_mesh().get_aabb() * cs[i].global_transform)
					

			elif vs.size() > 0 and not found_valid_shape:
				for i in vs.size():
					if i == 0:
						aabb = vs[i].get_aabb()
					else:
						aabb.merge(vs[i].get_aabb() * vs[i].global_transform)

			cur_obj.global_position.y -= aabb.position.y
			
		var rot_axis:Vector3 = dock.get_rotation_axis_from_options()
		if rot_axis != Vector3.ZERO: 
			cur_obj.rotate_object_local(rot_axis, PI/2)
		if queue_drop:
			clear_cur_obj()
			queue_drop = false

func _process(delta: float) -> void:
	if EditorInterface.get_selection().get_selected_nodes().size() == 0:
		#dock.show_warning(true)
		pass
	else:
		pass
		#dock.show_warning(false)
func clear_cur_obj() -> void:
	cur_obj.queue_free()
	cur_obj = null

func get_all_children(in_node,arr:=[]) -> Array:
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func get_nodes_of_type(in_array: Array, gd_class:Variant) -> Array:
	var arr: Array = []
	for i in in_array:
		if is_instance_of(i, gd_class):
			arr.append(i)
	return arr

func find_coll_shape(node):
	if node is CollisionShape3D:
		return node
	elif node.get_children() > 0:
		for i in node.get_children():
			return find_coll_shape(node)

func _on_item_selection_changed() -> void:
	if cur_obj:
		clear_cur_obj()
	if dock.is_scene_selected():
		# GUI INPUT doesn't work if no node is selected in the scene tree editor, thus we assure
		# that at least one node is selected
		var selec = EditorInterface.get_selection()
		if selec.get_selected_nodes().is_empty():
			selec.add_node(EditorInterface.get_edited_scene_root())
			
		var scene_path: String = dock.get_selected_scene()
		var root = EditorInterface.get_edited_scene_root()
		cur_obj = load(scene_path).instantiate() 
		root.add_child(cur_obj, false)
		dock.clear_selected_scene()
		
## NOTE: only works when any node in the scene is selected
func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if event is InputEventMouseButton and cur_obj:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			queue_drop = true
			dock.buttons_clear_pressed()
			return EditorPlugin.AFTER_GUI_INPUT_STOP
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_create_copy_of_cur_obj()
			
		return EditorPlugin.AFTER_GUI_INPUT_STOP #NOTE: stop right click, because it usually resets the node position
		## NOTE: also stop left click ofc
	
	
	if event is InputEventKey and dock.visible:
		if event.pressed:
			if event.keycode == KEY_1:
				dock.set_is_align_with_surface_pressed(!dock.get_is_align_with_surface_pressed())
			if event.keycode == KEY_2:
				dock.set_is_snap_to_floor_enabled(!dock.get_is_snap_to_floor_enabled())
			if event.keycode == KEY_3:
				dock.set_is_add_to_scene_root_enabled(!dock.get_is_add_to_scene_root_enabled())
			if event.keycode == KEY_4:
				if event.shift_pressed:
					dock.set_rotation_options_button_to_index(0)
				else:
					dock.set_rotation_options_button_to_next_option()
			if event.keycode == KEY_5:
				dock.set_is_snap_enabled(!dock.get_is_snap_enabled())
	return EditorPlugin.AFTER_GUI_INPUT_PASS
	
	
	
	
func _create_copy_of_cur_obj():
	
	var node = load(cur_obj.scene_file_path).instantiate()
	var parent: Node
	#if dock.get_is_add_to_scene_root_enabled():
	parent = EditorInterface.get_edited_scene_root()
	#else:
		#parent = EditorInterface.get_selection().get_selected_nodes()[0]
	var undo_redo = get_undo_redo()
	undo_redo.create_action("Add Node - Level Designer")
	undo_redo.add_do_method(parent,"add_child",node, true)
	undo_redo.add_do_reference(node)
	undo_redo.add_do_method(node, "set_owner", EditorInterface.get_edited_scene_root())
	undo_redo.add_do_property(node, "global_transform", cur_obj.global_transform)
	
	## NOTE: do not use queue_free for this but remove child, with free(), redo won't work but remove child does
	## because its just out of the tree and not removed
	undo_redo.add_undo_method(parent, "remove_child", node)
	undo_redo.commit_action()


func add_copy(node: Node, parent: Node, _owner: Node, g_position: Transform3D):
	#var node = load(scene).instantiate()
	parent.add_child(node,true)
	node.set_owner(_owner)
	node.global_transform = g_position
	pass
	



func get_physics_space_state() -> PhysicsDirectSpaceState3D:
	var viewport3D = EditorInterface.get_editor_viewport_3d(0)
	var camera = viewport3D.get_camera_3d()
	var world_3d = camera.get_world_3d()
	var event_position = viewport3D.get_mouse_position() #TEMP OVERRIDE OF EVENT_POS
	var space_state: PhysicsDirectSpaceState3D = world_3d.get_direct_space_state()
	return space_state
func _get_collision_data() -> Dictionary:#MUST BE CALLED WITHIN PHYSICS PROCESS BECAUSE SPACE STATE MUST ONLY BE ACCESSED THERE
	const RAY_LENGTH := 10000.0
	var viewport3D = EditorInterface.get_editor_viewport_3d(0)
	var camera = viewport3D.get_camera_3d()
	var world_3d = camera.get_world_3d()
	var event_position = viewport3D.get_mouse_position() #TEMP OVERRIDE OF EVENT_POS
	var space_state = world_3d.get_direct_space_state();
	var from = camera.project_ray_origin(event_position);
	var to = from + camera.project_ray_normal(event_position) * RAY_LENGTH; #OG
	#test
	
	var children:Array= get_all_children(cur_obj)
	var cs_obj: Array = get_nodes_of_type(children, CollisionObject3D)
	
	var csg_objects: Array = get_nodes_of_type(children, CSGShape3D)
	for csg in csg_objects:
		csg.use_collision = false
	
	var param := PhysicsRayQueryParameters3D.create(from,to, 0xFFFFFFFF,cs_obj)
	var result = space_state.intersect_ray(param)
	return result
