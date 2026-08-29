class_name InputRemapManager

signal input_key_changed(button_id: String, action_text: String)

var activated_button: InputButton

func _unhandled_input(event: InputEvent) -> void:
	if activated_button:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.keycode == KEY_ESCAPE:
				return
			InputMap.action_erase_events(activated_button.action)
			InputMap.action_add_event(activated_button.action, event)
			var action_text: String = get_action_bind_key(activated_button.action)
			activated_button.text = action_text
			input_key_changed.emit(activated_button.id, action_text)
			
			activated_button = null
			
func start_input_remap(button: InputButton):
	activated_button = button


func check_is_other_button_already_pressed():
	if activated_button:
		return true
	return false

func get_action_bind_key(action: String) -> String:
	var events = InputMap.action_get_events(action)
	var action_text: String
	for event in events:
		if event is InputEventKey:
			var key = OS.get_keycode_string(event.physical_keycode)
			action_text = key
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					action_text = "LMB"
				MOUSE_BUTTON_RIGHT:
					action_text= "RMB"
				MOUSE_BUTTON_WHEEL_UP:
					action_text = "MOUSE WHEEL UP"
				MOUSE_BUTTON_WHEEL_DOWN:
					action_text = "MOUSE WHEEL DOWN"
			break
	return action_text
