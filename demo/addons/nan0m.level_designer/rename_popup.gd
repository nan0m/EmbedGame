@tool
extends PopupPanel

signal text_submitted
#func _on_close_requested() -> void:
	#pass 
@onready var rename_line_edit: LineEdit = %RenameLineEdit

func _ready():
	rename_line_edit.grab_focus()
	
func _on_line_edit_text_submitted(new_text: String) -> void:
	text_submitted.emit(new_text)
	self.queue_free()


func set_text_to(new_text:String):
	rename_line_edit.insert_text_at_caret(new_text)
