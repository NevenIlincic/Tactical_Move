class_name InputRemapManager

var is_waiting_for_input: bool
var action_name: String

func _init() -> void:
	is_waiting_for_input = false
	action_name = "rotate_player"

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up"):
		is_waiting_for_input = true
		return
	if not is_waiting_for_input:
		return

	if event is InputEventKey or event is InputEventMouseButton:
		if event.keycode == KEY_ESCAPE:
			return
		print(event)
		InputMap.action_erase_events("rotate_player")
		InputMap.action_add_event(action_name, event)
	
func start_input_remap(current_action_name: String):
	action_name = current_action_name
	is_waiting_for_input = true
