@tool
extends ScrollContainer



func add_item_as_child(node: Node):
	self.get_child(0).add_child(node)

func get_items() -> Array[Node]:
	return self.get_child(0).get_children()
