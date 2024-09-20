extends Window

#var self : Window
func _ready() -> void:
	pass
	#get_parent().get_viewport().get_window().set_embedding_subwindows(false)
	#self.get_viewport().set_embedding_subwindows(false)
	self.position = get_parent().get_viewport().get_window().position
	#pass
	#self = Window.new()
	#self.name = "HelloWindow"
	#var view = SubViewport.new()
	#view.transparent_bg = true
	#self.add_child(view)
	#self.add_child(self)
	#self.set_owner(self.get_owner())
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print('a')
		#self.visible = ! self.visible
#func _notification(what: int) -> void:
	#if what == NOTIFICATION_VISIBILITY_CHANGED:
		#if not self.visible:
			#print('b')
			#self.get_parent().get_viewport().get_window().visible = false
		#else:
			##print()
			#self.get_parent().get_viewport().get_window().visible = false

func _process(delta: float) -> void:
	var pw = get_tree().root.get_window()

	var window_id = pw.get_window_id()
	print(DisplayServer.window_get_mode(window_id))
	print(pw.get_mode())
	#print(' 2 ', get_tree().root.get_window().get_mode())
	#print(self.name)
	#print(self.position)
	#printt(self.mode, self.size)
	#pw.
	#print(get_tree().root.get_window().position)
	#print(EditorInterface.get_edited_scene_root())
	#self.global_position = EditorInterface.get_base_control().position
	pass
	#if self.get_child(0) == null:
		#self.add_child(ColorRect.new())
	#self.get_child(0).set_owner(self.get_owner())
	##self.queue_free()
	#self.set_flag(Window.FLAG_POPUP, false)
	#self.transient = true
	#self.always_on_top = true
	##self.force_native = true
	#self.position = Vector2.ZERO
	#self.position.x += 10
	#pass
