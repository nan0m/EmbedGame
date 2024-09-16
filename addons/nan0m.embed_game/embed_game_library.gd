extends Node


static func get_window_mode_string(mode:int):
	match mode:
		0:
			return "DisplayServer.WINDOW_MODE_WINDOWED"
		1:
			return "DisplayServer.WINDOW_MODE_MINIMIZED"
		2:
			return "DisplayServer.WINDOW_MODE_MAXIMIZED"
		3:
			return "DisplayServer.WINDOW_MODE_FULLSCREEN"
		4:
			return "DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN"

static func get_window_flag_string(flag: int):
	match flag:
		0:
			return "WINDOW_FLAG_RESIZE_DISABLED"
		1:
			return "WINDOW_FLAG_BORDERLESS"
		2:
			return "WINDOW_FLAG_ALWAYS_ON_TOP"
		3:
			return "WINDOW_FLAG_TRANSPARENT"
		4:
			return "WINDOW_FLAG_NO_FOCUS"
		5:
			return "WINDOW_FLAG_POPUP"
		6:
			return "WINDOW_FLAG_EXTEND_TO_TITLE"
		7:
			return "WINDOW_FLAG_MOUSE_PASSTHROUGH"
		8:
			return "WINDOW_FLAG_MAX"
