@tool
extends EditorPlugin

# Go to 'wbg_autoload.gd' if you want to customize plugin.

var autoload_name := "WindowBGone"
var debugger :EditorDebuggerPlugin

class DebuggerScript extends EditorDebuggerPlugin:
	signal new_session(session:EditorDebuggerSession)
	func _setup_session(session_id:int) -> void:
		new_session.emit(get_session(session_id))


func _enter_tree() -> void:
	add_autoload_singleton(autoload_name, "wbg_autoload.gd")
	
	debugger = DebuggerScript.new()
	debugger.new_session.connect(_setup_new_session)
	add_debugger_plugin(debugger)


func _setup_new_session(session:EditorDebuggerSession) -> void:
	session.breaked.connect(_on_session_breaked.bind(session))
	session.continued.connect(_on_session_continued.bind(session))

func _on_session_breaked(can_debug:bool, session:EditorDebuggerSession) -> void:
	session.send_message(autoload_name + ":", ["breaked", get_window().current_screen])


func _on_session_continued(session:EditorDebuggerSession) -> void:
	session.send_message(autoload_name + ":", ["continued", get_window().current_screen])


func _exit_tree() -> void:
	remove_autoload_singleton(autoload_name)
	
	debugger.new_session.disconnect(_setup_new_session)
	for session in debugger.get_sessions():
		session.breaked.disconnect(_on_session_breaked)
		session.continued.disconnect(_on_session_continued)
	
	remove_debugger_plugin(debugger)
