class_name APConfigDialog extends AcceptDialog

var settings: APSettings
var xbutton1_check_box: CheckBox
var xbutton2_check_box: CheckBox

func _init(plugin_name: String, p_settings: APSettings) -> void:
	title = plugin_name + " Config"
	size = Vector2i(320, 160)
	
	settings = p_settings
	
	_build_contents(settings)

func _build_contents(settings: APSettings) -> void:
	var container := VBoxContainer.new()

	var description := Label.new()
	description.text = "Select which mouse buttons should pan the 2D editor."
	
	xbutton1_check_box = CheckBox.new()
	xbutton1_check_box.text = "Mouse Button 4"
	xbutton1_check_box.button_pressed = settings.xbutton1_enabled
	xbutton1_check_box.toggled.connect(_on_xbutton1_toggled)
	
	xbutton2_check_box = CheckBox.new()
	xbutton2_check_box.text = "Mouse Button 5"
	xbutton2_check_box.button_pressed = settings.xbutton2_enabled
	xbutton2_check_box.toggled.connect(_on_xbutton2_toggled)
	
	container.add_child(description)
	container.add_child(xbutton1_check_box)
	container.add_child(xbutton2_check_box)
	
	add_child(container)

func _on_xbutton1_toggled(enabled: bool) -> void:
	settings.xbutton1_enabled = enabled


func _on_xbutton2_toggled(enabled: bool) -> void:
	settings.xbutton2_enabled = enabled

func open() -> void:
	popup_centered()