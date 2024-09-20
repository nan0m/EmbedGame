extends Node3D


func _process(delta: float) -> void:
	#DebugDraw2D.create_fps_graph("FPS")
	#var graph = DebugDraw2D.create_graph("hello")
	#graph.corner = DebugDraw2DGraph.GraphPosition.POSITION_LEFT_TOP
	DebugDraw3D.draw_gizmo(self.transform)
	DebugDraw3D.draw_sphere_xf(self.transform)
	#DebugDraw3D.draw_arrow(self.global_position, self.position + Vector3(5,0,0), Color.RED,0.1)
	#DebugDraw3D.draw_position(self.global_transform)
	#DebugDraw3D.draw_line_hit(self.global_position, self.position + Vector3(5,0,0),Vector3(0,1,1),true)
	if Input.is_action_just_pressed("ui_accept"):
		pass

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#print('button')
	#if event is InputEventMouseMotion:
		#print('mouse motion')
