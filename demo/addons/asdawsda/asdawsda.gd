@tool
extends EditorPlugin

var embed_game := EmbedWindow.new()
var child_hwnd : int 
var is_active: bool = false
func _enter_tree() -> void:
	pass
 
func get_self_handle() -> int:
	var window_id: int = self.get_window().get_window_id()
	return DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, window_id)

func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("ui_down"):
		if child_hwnd == 0:
			child_hwnd = embed_game.get_hwnd_by_title("New Game Project (DEBUG)")
			print(child_hwnd)
	if Input.is_action_just_pressed("ui_right"):
		if child_hwnd != 0:
			embed_game.make_child(get_self_handle(), child_hwnd)
			embed_game.set_window_borderless(child_hwnd)
	if Input.is_action_just_pressed("ui_left"):
		if child_hwnd != 0:
			embed_game.unmake_child(child_hwnd)
	if Input.is_action_just_pressed("ui_up"):
		if child_hwnd != 0:
			is_active = !is_active
			print('is active ', is_active)
			pass

var last_rect: Rect2i
func _process(delta: float) -> void:
	if is_active and child_hwnd != 0:
		var main_screen := EditorInterface.get_editor_main_screen() ##positio in the window
		var window = main_screen.get_window()
		
		var rect: Rect2i = Rect2i(
		main_screen.global_position.x - main_screen.global_position.x * 0.0,
		main_screen.global_position.y - main_screen.global_position.y * 0.0,
		main_screen.size.x - main_screen.size.x * 0.0,
		main_screen.size.y - main_screen.size.y * 0.0
		)
		if rect != last_rect:
			last_rect = rect
			embed_game.set_window_rect(child_hwnd,rect)
	pass
	
func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
 
