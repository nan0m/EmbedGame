#extends GDExample

#func _ready() -> void:
	#var child_handle: int = self.get_hwnd_by_title("Untitled - Notepad")
	#self.set_window_rect(child_handle, Rect2i(Vector2i.ZERO, Vector2i.ONE * 700))
	#var parent_handle: int = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, self.get_window().get_window_id())
	#self.make_child(parent_handle, child_handle)
