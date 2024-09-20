extends Node

# Edit this if you want to, see details below.
@export var plugin_mode := PLUGIN_MODE.STANDARD # Editable at runtime, probably fine to do.
enum PLUGIN_MODE {
	DETECT_OVERLAP, # Will auto-detect when the game would be on top of the editor,
					# only works on AlwaysOnTop and or ExclusiveFullscreen windows.
	
	STANDARD,       # Will always minimize AlwaysOnTop and or ExclusiveFullscreen windows.
	
	FORCE_MINIMIZE, # Will force a minimize no matter what. Unrecommended, as Godot should
					# focus itself in all other Window modes.
	
	DISABLED        # Disables plugin. Recommended to disable the plugin in editor instead.
}
func set_mode(mode:PLUGIN_MODE) -> void:
	plugin_mode = mode

# Overrides, in case you prefer one not being minimized.
# Only applies to plugin_mode STANDARD and DETECT_OVERLAP.
@export var ignore_always_on_top        := false
@export var ignore_exclusive_fullscreen := false

var previous_window_mode :int


func _ready() -> void:
	if !OS.has_feature("editor"):
		print_rich("---\n[color=yellow]Window-B-Gone will disable itself in exported builds. Now freeing autoload.[/color]\n---")
		queue_free()
		return
	
	previous_window_mode = -1
	EngineDebugger.register_message_capture("WindowBGone", _on_plugin_message)


func _on_plugin_message(message:String, data:Array) -> bool:
	var window := get_window()
	
	match plugin_mode:
		PLUGIN_MODE.DETECT_OVERLAP, PLUGIN_MODE.STANDARD:
			if plugin_mode == PLUGIN_MODE.DETECT_OVERLAP && data[1] != window.current_screen:
				return true
			
			if !ignore_always_on_top && window.always_on_top:
				pass
			elif !ignore_exclusive_fullscreen && window.get_mode()    == Window.MODE_EXCLUSIVE_FULLSCREEN:
				pass
			elif !ignore_exclusive_fullscreen && previous_window_mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
				pass
			else:
				return true
		
		PLUGIN_MODE.FORCE_MINIMIZE: pass
		PLUGIN_MODE.DISABLED: return true
	
	match data[0]:
		"breaked":
			previous_window_mode = window.get_mode()
			window.set_mode(Window.MODE_MINIMIZED)
		"continued":
			window.set_mode(previous_window_mode)
			previous_window_mode = -1
	return true
