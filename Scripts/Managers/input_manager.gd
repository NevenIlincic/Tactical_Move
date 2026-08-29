class_name InputRemapManager

var is_waiting_for_input: bool
var action_name: String
var activated_button: Button

func _init() -> void:
	is_waiting_for_input = false
	action_name = "rotate_player"

func activate_waiting_for_input():
	is_waiting_for_input = true
func deactivate_waiting_for_input():
	is_waiting_for_input = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up"):
		is_waiting_for_input = true
		return
	if not is_waiting_for_input:
		return

	if event is InputEventKey or event is InputEventMouseButton:
		if event.keycode == KEY_ESCAPE:
			return
		InputMap.action_erase_events("rotate_player")
		InputMap.action_add_event(action_name, event)
	
func start_input_remap(current_action_name: String):
	action_name = current_action_name
	activate_waiting_for_input()


func get_initial_action_bind_key(button: Button, action: String):
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			var key = OS.get_keycode_string(event.physical_keycode)
			button.text = key
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					button.text = "LMB"
				MOUSE_BUTTON_RIGHT:
					button.text = "RMB"
				MOUSE_BUTTON_WHEEL_UP:
					button.text = "MOUSE WHEEL UP"
				MOUSE_BUTTON_WHEEL_DOWN:
					button.text = "MOUSE WHEEL DOWN"
			break
