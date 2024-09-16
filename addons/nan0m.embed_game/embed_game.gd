@tool
extends EditorPlugin

const debug: bool = false
const library = preload("res://addons/nan0m.embed_game/embed_game_library.gd")
var debugger: EditorDebugger
var sesh: EditorDebuggerSession
var last_window_position: Vector2i
var plugin_control: PanelContainer
var hbox: HBoxContainer
var activate_button: Button
var top_bar_button: Button
var last_main_screen_not_embed: String
var is_playing_scene: bool
var was_playing_scene: bool
var last_update: Array
var is_mouse_inside:= true
var last_window_mode = DisplayServer.WINDOW_MODE_WINDOWED

#region Debugger Setup
class EditorDebugger extends EditorDebuggerPlugin:
	signal new_session(session:EditorDebuggerSession)
	signal _on_request_embed_status(session: EditorDebuggerSession)
	signal _on_return_focus(session: EditorDebuggerSession)
	func _has_capture(prefix):
		if debug: print('message prefix ', prefix)
		if prefix == "request_embed_status": return true
		if prefix == "return_focus": return true
		return true
		
	func _capture(message, data, session_id):
		if message == "request_embed_status:":
			_on_request_embed_status.emit(get_session(session_id))
			return true
		if message == "return_focus:":
			_on_return_focus.emit(data)
			return true
	func _setup_session(session_id):
		new_session.emit(get_session(session_id))
		
func register_debugger_session(dbgs: EditorDebuggerSession):
	sesh = dbgs
#endregion

#region Editor Plugin specific functions

## main screen plugin setup
func _has_main_screen():
	return true
	
func _get_plugin_name():
	return "Embed"
	
func _make_visible(visible):
	plugin_control.visible = visible
func _get_plugin_icon():
	return preload("res://addons/nan0m.embed_game/assets/embed_icon.svg")

func _enter_tree():
	add_autoload_singleton("EmbedGameAutoload","res://addons/nan0m.embed_game/embed_game_autoload.gd")
	
	## add checkbutton and reparent 'embed' button
	_add_control_elements()
	
	## CONNECT SIGNALS
	debugger = EditorDebugger.new()
	debugger.new_session.connect(register_debugger_session)
	debugger._on_request_embed_status.connect(self._on_request_embed_status)
	debugger._on_return_focus.connect(self._on_return_focus)
	add_debugger_plugin(debugger)
	
	##connect main screen size to game window
	var main_screen := EditorInterface.get_editor_main_screen()
	main_screen.resized.connect(send_placement_update) ## UPDATE PLACEMENT WHEN MAIN VIEW HAS CHANGED BUT NOT WHEN EDITOR HAS CHANGED POSITION
	main_screen_changed.connect(_on_main_screen_changed)
	
	self.get_window().focus_entered.connect(send_focus_update)
	self.get_window().focus_exited.connect(send_focus_update)
	self.get_window().mouse_entered.connect(send_focus_update)
	self.get_window().mouse_exited.connect(send_focus_update)
	
func _on_activate_button_toggled(flag: bool):
	self.queue_save_layout() ## saves setting
	if flag:
		embed_window()
		if is_playing_scene:
			top_bar_button.visible = true
			EditorInterface.set_main_screen_editor("Embed")
			
	else:
		unembed_window()
		set_always_on_top(false)
		EditorInterface.set_main_screen_editor(last_main_screen_not_embed)
		plugin_control.visible = false
		top_bar_button.visible = false
	
func _exit_tree():
	hbox.queue_free()
	remove_debugger_plugin(debugger)
	remove_autoload_singleton("EmbedGameAutoload")

func _build():
	if activate_button.button_pressed:
		top_bar_button.visible = true
		EditorInterface.set_main_screen_editor("Embed")
	return true

func _get_window_layout(configuration: ConfigFile) -> void:
	configuration.set_value("embed_window", "is_enabled", activate_button.button_pressed)
	
func _set_window_layout(configuration: ConfigFile) -> void:
	activate_button.button_pressed = configuration.get_value("embed_window","is_enabled", false)

func _add_control_elements():
	var top_buttons:= get_top_buttons()
	for i in top_buttons:
		if i.text == "Embed":
			top_bar_button = i
	hbox = HBoxContainer.new()
	hbox.name = "Embed"
	last_main_screen_not_embed = top_buttons[0].name ## so it's never an empty string
	top_bar_button.get_parent().add_child(hbox)
	top_bar_button.reparent(hbox)
	top_bar_button.shortcut = load("res://addons/nan0m.embed_game/config/embed_shortcut.tres")
	top_bar_button.visible = false
	activate_button = preload("res://addons/nan0m.embed_game/embed_button.tscn").instantiate()
	activate_button.toggled.connect(_on_activate_button_toggled)
	hbox.add_child(activate_button,true)
	
	## add empty panel
	plugin_control = PanelContainer.new()
	EditorInterface.get_editor_main_screen().add_child(plugin_control)
	plugin_control.hide()
	
	was_playing_scene = EditorInterface.get_playing_scene() != ""
	is_playing_scene = EditorInterface.get_playing_scene() != ""
	
#endregion
func _process(delta: float) -> void:
	if not activate_button.button_pressed: return
	
	## minimize the play window if the editor is minimized
	if self.get_window().mode != last_window_mode:
		if get_window().mode == Window.Mode.MODE_MINIMIZED:
			set_window_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
		else:
			set_window_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	last_window_mode = get_window().mode 
	
	## only reliable way of getting this correctly omg....
	var cur_mouse: bool = _is_mouse_in_editor()
	if is_mouse_inside != cur_mouse:
		is_mouse_inside = cur_mouse
		send_focus_update()
		
	## UPDATE PLACEMENT WHEN MOVING EDITOR WINDOW ONLY
	var main_screen := EditorInterface.get_editor_main_screen()
	var window_position: Vector2i = main_screen.get_window().position
	if window_position != last_window_position:
		send_placement_update()
		last_window_position = window_position
	
	
	### WHEN TO HIDE EMBED VIEW FOR SOMETHING ELSE
	for i in DisplayServer.get_window_list():
		if not is_window_opening_allowed_during_embed(i):
			var main_view_rect: Rect2 = get_main_screen_rect()
			var pos := DisplayServer.window_get_position_with_decorations(i)
			var size: = DisplayServer.window_get_size_with_decorations(i)
			var window_rect := Rect2i(pos, size)
			if main_view_rect.intersects(window_rect):
				EditorInterface.set_main_screen_editor(last_main_screen_not_embed)

	## removes embed view on quitting the play mode
	is_playing_scene = EditorInterface.get_playing_scene() != ""
	if was_playing_scene and not is_playing_scene:
		top_bar_button.visible = false
		EditorInterface.set_main_screen_editor(last_main_screen_not_embed)
	was_playing_scene = is_playing_scene
	



#region Received From Autoload
func _on_request_embed_status(dbgs: EditorDebuggerSession):
	if activate_button.button_pressed: 
		send_placement_update()
		embed_window()

func _on_return_focus(data):
	var keycode: int = data[0]
	var f_key_number = keycode - 4194332 
	var top_buttons:= get_top_buttons()
	if f_key_number < top_buttons.size():
		var desired_tab: String = top_buttons[f_key_number].name
		EditorInterface.set_main_screen_editor(desired_tab)
#endregion

#region Window Management

func send_focus_update():
	var editor_focused = self.get_window().has_focus()
	var mouse_in_editor = is_mouse_inside
	var plugin_enabled: bool = activate_button.button_pressed
	var update = [ editor_focused, mouse_in_editor]
	if update != last_update:
		sesh.send_message("editor_state_update:", [editor_focused, mouse_in_editor, plugin_enabled])
	last_update = update

func send_placement_update():
	if activate_button.button_pressed:
		const padding = Vector2i(2,2)
		var main_screen := EditorInterface.get_editor_main_screen()
		var window_position = main_screen.get_window().position 
		sesh.send_message("update_size:", [Vector2i(main_screen.size) - padding , window_position + Vector2i(main_screen.global_position) + padding/2 ])

func embed_window() -> void:
	sesh.send_message("embed:", [true])
	send_placement_update()
	
func unembed_window() -> void:
	sesh.send_message("embed:", [false])

func _on_main_screen_changed(screen_name: String) -> void:
	if screen_name != "Embed":
		last_main_screen_not_embed = screen_name
		if activate_button.button_pressed:
			set_window_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	else:
		set_window_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_always_on_top(flag:bool):
	sesh.send_message("set_flag:", [DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, flag])

func set_window_flag(window_flag: DisplayServer.WindowFlags, active: bool) -> void:
	if debug: print("set_window_flag ", library.get_window_flag_string(window_flag), active)
	sesh.send_message("set_flag:", [window_flag, active])
	pass
	
func set_window_mode(mode: DisplayServer.WindowMode):
	if debug: print("set window mode ", library.get_window_mode_string(mode))
	sesh.send_message("set_mode:", [mode])
#endregion

#region Helper Functions
func get_top_buttons() -> Array[Node]:
	var cont := Control.new()
	add_control_to_container(CustomControlContainer.CONTAINER_TOOLBAR, cont)
	var btns := cont.get_parent().get_child(2).get_children()
	remove_control_from_container(CustomControlContainer.CONTAINER_TOOLBAR, cont)
	return btns
	
func get_main_screen_rect() -> Rect2i:
	var main_screen : = EditorInterface.get_editor_main_screen()
	var window_position: Vector2i = main_screen.get_window().position 
	return Rect2i(
		window_position + Vector2i(main_screen.global_position),
		main_screen.size 
	)

func _is_mouse_in_editor() -> bool:
	var mouse_pos := DisplayServer.mouse_get_position()
	var editor := Rect2(self.get_window().get_position_with_decorations(),self.get_window().get_size_with_decorations() )
	#var editor := Rect2(self.get_window().position,self.get_window().size )
	return editor.has_point(mouse_pos)

func _is_mouse_in_container(container: Container) -> bool:
	var mouse_pos := DisplayServer.mouse_get_position()
	var cont_rect = Rect2(container.global_position + Vector2(self.get_viewport().get_window().position) ,
	container.size)
	return cont_rect.has_point(mouse_pos)

func is_window_opening_allowed_during_embed(window) -> bool:
	var window_name: String = instance_from_id(DisplayServer.window_get_attached_instance_id(window)).name
	## partial match
	const remain_windows = ["root", "PopupPanel", "PopupPanel", "PopupMenu","Tooltip"]
	for window_title in remain_windows:
		if window_name.containsn(window_title):
			return true
	## exact match
	if window_name in ["Debug", "Project", "Editor"]: return true
	return false
#endregion
