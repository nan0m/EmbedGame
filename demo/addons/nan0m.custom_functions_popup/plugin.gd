@tool
extends EditorPlugin


var popup
var popup_open: bool = false


func _enter_tree():
	popup = preload("res://addons/nan0m.custom_functions_popup/popup.tscn").instantiate()
	var parent = EditorInterface.get_base_control()
	parent.add_child(popup)
	popup.set_owner(self.get_owner())
	popup.hide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and not popup_open:
		if event.key_label == KEY_TAB and event.pressed and event.ctrl_pressed:
			var mouse_pos = DisplayServer.mouse_get_position()
			
			popup.popup(Rect2(
			mouse_pos.x - popup.size.x /2, 
			mouse_pos.y,
			popup.size.x,
			popup.size.y))


func _exit_tree():
	popup.queue_free()
