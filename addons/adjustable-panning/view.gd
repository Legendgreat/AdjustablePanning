class_name APView extends RefCounted

var type_name: String
var control: Control
var callback: Callable

func _init(
	p_type_name: String,
	p_control: Control,
	p_callback: Callable
) -> void:
	type_name = p_type_name
	control = p_control
	callback = p_callback