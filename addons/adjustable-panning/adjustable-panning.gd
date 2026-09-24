@tool
extends EditorPlugin

const NAME := "Adjustable Panning"

# func _enter_tree() -> void:
# 	_connect_viewport_inputs()
# 	_add_tool_submenu()
# 	_setup_config_menu()
# 
# func _exit_tree() -> void:
# 	_disconnect_viewport_input()
# 	_remove_tool_submenu()
# 	_cleanup_config_menu()

var settings: APSettings
var input_handler: APInputHandler
var view_manager: APViewManager
var config_dialog: APConfigDialog
var menu_manager: APMenuManager

func _enter_tree() -> void:
	settings = APSettings.new()
	input_handler = APInputHandler.new(settings)
	view_manager = APViewManager.new(input_handler)
	config_dialog = APConfigDialog.new(NAME, settings)
	menu_manager = APMenuManager.new(self, NAME, config_dialog)
	
	EditorInterface.get_base_control().add_child(config_dialog)
	
	view_manager.connect_view_inputs()
	

func _exit_tree() -> void:
	menu_manager.remove_menu()
	
	view_manager.disconnect_view_inputs()
	config_dialog.queue_free()