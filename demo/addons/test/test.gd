@tool
extends EditorPlugin

var window
func _enter_tree() -> void:
	window = Window.new()
	window.name = "HelloWindow"
	var view = SubViewport.new()
	view.transparent_bg = true
	window.add_child(view)
	EditorInterface.get_editor_main_screen().add_child(window)
	window.set_owner(EditorInterface.get_editor_main_screen().get_owner())
	
	printt(window, window.get_parent())
	# Initialization of the plugin goes here.
	pass


func _process(delta: float) -> void:
	var win_list = DisplayServer.get_window_list()
	#print(win_list)
	#DisplayServer.window_set_transient(2, 0)
	var w : Window = window
	w.transient = true
	w.transient_to_focused = true
	#w.exclusive = true
	#await get_tree().create_timer(4.).timeout
	#w.exclusive = false
	#w.transparent = true
	#w.transient = true
	#w.set_transient_to_focused(true)
	w.position = EditorInterface.get_editor_main_screen().global_position + Vector2(self.get_window().get_position_with_decorations())
	pass
func _exit_tree() -> void:
	window.queue_free()
	# Clean-up of the plugin goes here.
	pass
