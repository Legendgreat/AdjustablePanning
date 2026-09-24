class_name APSettings extends RefCounted

const XBUTTON1_KEY := "adjustable_panning/mouse_button_4"
const XBUTTON2_KEY := "adjustable_panning/mouse_button_5" 

var xbutton1_enabled: bool
var xbutton2_enabled: bool

var editor_settings: EditorSettings

func _init() -> void:
	editor_settings = EditorInterface.get_editor_settings()
	
	if not editor_settings.has_setting(XBUTTON1_KEY):
		editor_settings.set_setting(XBUTTON1_KEY, false)
		
	if not editor_settings.has_setting(XBUTTON2_KEY):
		editor_settings.set_setting(XBUTTON2_KEY, true)
	
	xbutton1_enabled = editor_settings.get_setting(XBUTTON1_KEY)
	xbutton2_enabled = editor_settings.get_setting(XBUTTON2_KEY)

func set_xbutton1_enabled(enabled: bool) -> void:
	xbutton1_enabled = enabled
	editor_settings.set_setting(XBUTTON1_KEY, enabled)

func set_xbutton2_enabled(enabled: bool) -> void:
	xbutton2_enabled = enabled
	editor_settings.set_setting(XBUTTON2_KEY, enabled)

func is_pan_button(button: MouseButton) -> bool:
	if button == MOUSE_BUTTON_XBUTTON1:
		return xbutton1_enabled
	
	if button == MOUSE_BUTTON_XBUTTON2:
		return xbutton2_enabled
	
	return false