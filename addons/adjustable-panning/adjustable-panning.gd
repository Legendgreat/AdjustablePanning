@tool
extends EditorPlugin

const XBUTTON_1_SETTING := "adjustable_panning/mouse_button_4"
const XBUTTON_2_SETTING := "adjustable_panning/mouse_button_5"

const PLUGIN_NAME := "Adjustable Panning"

const CLASS_NAMES := [
	"CanvasItemEditorViewport", 
	"TileAtlasView", 
	"GenericTilePolygonEditor", 
]

var viewport_dict: Dictionary[Control, String]
var viewport_callbacks: Dictionary[Control, Callable]

var config_dialog: AcceptDialog
var xbutton1_check_box: CheckBox
var xbutton2_check_box: CheckBox

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton

		if mouse_button.button_index == MOUSE_BUTTON_MIDDLE:
			print(
					"PLUGIN INPUT MB3: ",
					mouse_button.position
			)

func _enter_tree() -> void:
	_connect_viewport_inputs()
	_add_tool_submenu()
	_setup_config_menu()

func _exit_tree() -> void:
	_disconnect_viewport_input()
	_remove_tool_submenu()
	_cleanup_config_menu()

func _on_viewport_gui_input(event: InputEvent, viewport: Control) -> void:
	if not event is InputEventMouseButton:
		return
	
	print(viewport.get_class(), ": ", event)

	if not _is_configured_button(event.button_index):
		return

	var middle_button := InputEventMouseButton.new()
	middle_button.button_index = MOUSE_BUTTON_MIDDLE
	middle_button.pressed = event.pressed
	middle_button.position = event.position
	middle_button.global_position = event.global_position

	viewport.get_viewport().push_input(middle_button)

func _is_configured_button(button: MouseButton) -> bool:
	var settings := EditorInterface.get_editor_settings()

	match button:
		MOUSE_BUTTON_XBUTTON1:
			return settings.get_setting(XBUTTON_1_SETTING) as bool

		MOUSE_BUTTON_XBUTTON2:
			return settings.get_setting(XBUTTON_2_SETTING) as bool
		
		_:
			return false

func _connect_viewport_inputs() -> void:
	for c in CLASS_NAMES:
		var viewports := _find_control_by_class(
			EditorInterface.get_base_control(),
			c
		)
		
		for viewport in viewports:
			var callback := _on_viewport_gui_input.bind(viewport)
			viewport.gui_input.connect(callback)
			
			viewport_dict[viewport] = c
			viewport_callbacks[viewport] = callback
		

func _disconnect_viewport_input() -> void:
	for viewport in viewport_dict:
		var callback: Callable = viewport_callbacks[viewport]
		
		if is_instance_valid(viewport):
			viewport.gui_input.disconnect(callback)
	
	viewport_dict.clear()
	viewport_callbacks.clear()
	
		
func _add_tool_submenu() -> void:
	var tool_menu: PopupMenu = PopupMenu.new()
	tool_menu.index_pressed.connect(_tool_menu_handler)
	
	tool_menu.add_item("Open Config...")
	# tool_menu.add_separator()
	# tool_menu.add_item("Reload Plugin")
	
	add_tool_submenu_item(PLUGIN_NAME, tool_menu)

func _remove_tool_submenu() -> void:
	remove_tool_menu_item(PLUGIN_NAME)

func _tool_menu_handler(index: int) -> void:
	match index:
		0:
			_open_config()
	
func _setup_config_menu() -> void:
	var editor_settings := EditorInterface.get_editor_settings()

	if not editor_settings.has_setting(XBUTTON_1_SETTING):
		editor_settings.set_setting(XBUTTON_1_SETTING, false)

	if not editor_settings.has_setting(XBUTTON_2_SETTING):
		editor_settings.set_setting(XBUTTON_2_SETTING, true)

func _open_config() -> void:
	if is_instance_valid(config_dialog):
		config_dialog.popup_centered()
		return
	
	var settings := EditorInterface.get_editor_settings()
	
	config_dialog = AcceptDialog.new()
	config_dialog.title = PLUGIN_NAME + " Config"
	config_dialog.size = Vector2i(320, 160)
	
	var container := VBoxContainer.new()
	
	var description := Label.new()
	description.text = "Select which mouse buttons should pan the 2D editor."
	
	xbutton1_check_box = CheckBox.new()
	xbutton1_check_box.text = "Mouse Button 4"
	xbutton1_check_box.button_pressed = settings.get_setting(XBUTTON_1_SETTING)
	
	xbutton2_check_box = CheckBox.new()
	xbutton2_check_box.text = "Mouse Button 5"
	xbutton2_check_box.button_pressed = settings.get_setting(XBUTTON_2_SETTING)
	
	container.add_child(description)
	container.add_child(xbutton1_check_box)
	container.add_child(xbutton2_check_box)
	
	config_dialog.add_child(container)
	
	EditorInterface.get_base_control().add_child(config_dialog)
	
	config_dialog.confirmed.connect(_save_settings)
	config_dialog.canceled.connect(_cleanup_config_menu)
	
	config_dialog.popup_centered()
	
	print(viewport_dict)

func _save_settings() -> void:
	EditorInterface.get_editor_settings().set_setting(
			XBUTTON_1_SETTING,
			xbutton1_check_box.button_pressed
	)
	
	EditorInterface.get_editor_settings().set_setting(
			XBUTTON_2_SETTING,
			xbutton2_check_box.button_pressed
	)
	
	_cleanup_config_menu()

func _cleanup_config_menu() -> void:
	if is_instance_valid(config_dialog):
		config_dialog.queue_free()
	
	config_dialog = null
	xbutton1_check_box = null
	xbutton2_check_box = null

func _find_control_by_class(node: Node, _class_name: String) -> Array[Control]:
	var results: Array[Control] = []
	
	if node is Control and node.get_class() == _class_name:
		results.append(node)
	
	for child in node.get_children():
		results.append_array(_find_control_by_class(child, _class_name))
	
	return results

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
