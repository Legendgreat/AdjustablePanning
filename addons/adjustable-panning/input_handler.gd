class_name APInputHandler extends RefCounted

var settings: APSettings

func _init(p_settings: APSettings):
	settings = p_settings

func handle(event: InputEvent, control: Control):
	if not event is InputEventMouseButton:
		return
		
	if not settings.is_pan_button(event.button_index):
		return
	
	var middle_button := InputEventMouseButton.new()
	middle_button.button_index = MOUSE_BUTTON_MIDDLE
	middle_button.pressed = event.pressed
	middle_button.position = event.position
	middle_button.global_position = event.global_position
	
	control.get_viewport().push_input(middle_button)