extends Node

const debug_enabled = false
var window_conf_startup: WindowConfig
const library = preload("res://addons/fabimakesgames.embed_game/embed_game_library.gd")
var is_editor_focused: bool

class WindowConfig:
	var window_flags: Array[bool]
	var window_mode: int
	var position: Vector2i
	var size: Vector2i 

func _ready() -> void:
	if !OS.has_feature("editor"): ## remove plugin autoloads in exported builds
		queue_free()

	_store_window_conf_startup_config()
	EngineDebugger.register_message_capture("update_size", _update_size_message)
	EngineDebugger.register_message_capture("embed", _on_embed_message)
	EngineDebugger.register_message_capture("set_flag", _on_set_flag_message)
	EngineDebugger.register_message_capture("set_mode", _on_set_mode_message)
	EngineDebugger.register_message_capture("editor_state_update", _on_editor_state_update)
	EngineDebugger.send_message("request_embed_status:",[])


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.ctrl_pressed and event.pressed:
				if event.keycode >= KEY_F1 and event.keycode <= KEY_F9:
					EngineDebugger.send_message("return_focus:", [event.keycode])

## MESSAGES
#region Receive Messages
func _on_editor_state_update(message: String, data:Array):
	var plugin_enabled = data[2]
	if not plugin_enabled: return true
	var w_id = self.get_window().get_window_id()
	var is_editor_focused: bool = data[0]
	is_editor_focused = data[0]
	var mouse_in_editor: bool = data[1]
	var win: Window = self.get_tree().root.get_window()

	if is_editor_focused:
		if not mouse_in_editor :
			self.get_window().set_flag(Window.FLAG_ALWAYS_ON_TOP, false)
		else:
			self.get_window().set_flag(Window.FLAG_ALWAYS_ON_TOP, true)
	elif not is_editor_focused and not win.has_focus():
		self.get_window().set_flag(Window.FLAG_ALWAYS_ON_TOP, false)
	return true


func _update_size_message(message:String, data:Array) -> bool:
	var size : Vector2i = data[0]
	var global_position : Vector2i = data[1]
	DisplayServer.window_set_size(size)
	DisplayServer.window_set_position(global_position,0)
	return true

func _on_set_flag_message(message: String, data:Array):
	if debug_enabled: printt(" auto set flag ", library.get_window_flag_string(data[0]), data[1])
	var flag: int = data[0]
	var value: bool = data[1]
	DisplayServer.window_set_flag(flag, value)
	return true

func _on_set_mode_message(message: String, data:Array) -> bool:
	if debug_enabled: print("auto set mode ", library.get_window_mode_string(data[0]) )
	var mode: int = data[0]
	DisplayServer.window_set_mode(mode)
	return true
	
func _on_embed_message(message: String, data:Array) -> bool:
	var do_embed: bool = data[0]
	if debug_enabled: print('auto embed ', data[0])
	if do_embed:
		_store_window_conf_startup_config()
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED,true)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP,true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	else:
		DisplayServer.window_set_position(window_conf_startup.position)
		DisplayServer.window_set_size(window_conf_startup.size)
		DisplayServer.window_set_mode(window_conf_startup.window_mode)
		for i in DisplayServer.WINDOW_FLAG_MAX:
			if i == DisplayServer.WINDOW_FLAG_POPUP: continue ## Main Window can never be popup, would cause error statement else
			DisplayServer.window_set_flag(i, window_conf_startup.window_flags[i])
	return true
#endregion

func _store_window_conf_startup_config():
	var wc := WindowConfig.new()
	for i in DisplayServer.WINDOW_FLAG_MAX:
		wc.window_flags.append(DisplayServer.window_get_flag(i) )
	wc.position = DisplayServer.window_get_position(0)
	wc.size = DisplayServer.window_get_size(0)
	wc.window_mode = DisplayServer.window_get_mode(0)
	window_conf_startup = wc
