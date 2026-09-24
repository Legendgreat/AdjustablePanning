class_name APMenuManager extends RefCounted

var config_dialog: APConfigDialog
var tool_menu: PopupMenu
var plugin: EditorPlugin
var name: String

func _init(p_plugin: EditorPlugin, p_name: String, p_config_dialog: APConfigDialog) -> void:
	config_dialog = p_config_dialog
	plugin = p_plugin
	name = p_name
	_add_tool_submenu()

func _add_tool_submenu() -> void:
	tool_menu = PopupMenu.new()
	tool_menu.index_pressed.connect(_tool_menu_handler)

	tool_menu.add_item("Open Config...")
	# tool_menu.add_separator()
	# tool_menu.add_item("Reload Plugin")

	plugin.add_tool_submenu_item(name, tool_menu)

func _tool_menu_handler(index: int) -> void:
	match index:
		0:
			config_dialog.open()

func remove_menu() -> void:
	plugin.remove_tool_menu_item(name)
	