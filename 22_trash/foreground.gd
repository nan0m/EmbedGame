extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_parent().print_tree_pretty()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var window_id = self.get_viewport().get_window().get_window_id()
	#DisplayServer.window_move_to_foreground(window_id)
	pass
