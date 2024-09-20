@tool
extends CheckButton

@export var nodes_to_hide: Array[Control]


func _ready() -> void:
	pressed.connect(Callable(self, "_on_show_advanced_button_pressed"))
	pass 

func _on_show_advanced_button_pressed():
	for i in nodes_to_hide:
		i.visible = button_pressed
