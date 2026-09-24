class_name APViewManager extends RefCounted

const CLASS_NAMES := [
	"CanvasItemEditorViewport",
	"TileAtlasView",
	"GenericTilePolygonEditor",
]

var input_handler: APInputHandler
var views: Array[APView]

func _init(p_input_handler: APInputHandler):
	input_handler = p_input_handler

func connect_view_inputs() -> void:
	for _class in CLASS_NAMES:
		var controls := _find_control_by_class(
			EditorInterface.get_base_control(),
			_class
		)

		for control in controls:
			_connect_control(_class, control)

func disconnect_view_inputs() -> void:
	for view in views:
		view.control.gui_input.disconnect(view.callback)

	views.clear()

func _connect_control(_class: String, control: Control) -> void:
	var callback := input_handler.handle.bind(control)
	
	control.gui_input.connect(callback)
	
	views.append(APView.new(_class, control, callback))

func _find_control_by_class(node: Node, _class_name: String) -> Array[Control]:
	var results: Array[Control] = []

	if node is Control and node.get_class() == _class_name:
		results.append(node)

	for child in node.get_children():
		results.append_array(_find_control_by_class(child, _class_name))
	
	return results