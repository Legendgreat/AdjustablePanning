class_name APDebugging extends RefCounted

func _dump_controls(node: Node, indent := 0) -> void:
	if node is Control:
		print(
			"  ".repeat(indent),
			node.get_class(),
			" | ",
			node.name
		)
	
	for child in node.get_children():
		_dump_controls(child, indent + 1)