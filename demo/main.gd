extends Node2D

#var embedgame 
#var child_hwnd: int = 0
#func _ready() -> void:
	#embedgame= EmbedWindow.new()
	#print(embedgame)
	#pass
	##await get_tree().create_timer(2.).timeout
	##var s = EmbedGm
	##var s = EmbedWindow.new()
	##print(s.get_hwnd_by_title('New Game Project (DEBUG)'))
	##self.add_child(s)
	##s.set_owner(self.get_tree().root)
	##var child_hwnd = s.get_hwnd_by_title("New Game Project (DEBUG)")
	##var p_hwnd = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, self.get_window().get_window_id())
	##s.make_child(p_hwnd, child_hwnd)
	##pass
 #
#func get_self_handle() -> int:
	#var window_id: int = self.get_window().get_window_id()
	#return DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, window_id)
#
##func _input(event: InputEvent) -> void:
	##
	##if Input.is_action_just_pressed("ui_down"):
		#child_hwnd = embedgame.get_hwnd_by_title("New Game Project (DEBUG)")
		#print(child_hwnd)
	#if Input.is_action_just_pressed("ui_right"):
		#if child_hwnd != 0:
			#embedgame.make_child(get_self_handle(), child_hwnd)
	#if Input.is_action_just_pressed("ui_left"):
		#if child_hwnd != 0:
			#embedgame.unmake_child(child_hwnd)
