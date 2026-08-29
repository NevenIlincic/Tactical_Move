class_name InputButton extends Button

var id: String
@export var action: String

var input_remap_manager: InputRemapManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id = str(Time.get_ticks_usec(), "_", randi())
	get_action_bind_key()

func set_input_remap_manager(manager: InputRemapManager):
	input_remap_manager = manager

func check_is_same_action_key_bind(button_id: String, button_text: String):
	if id != button_id:
		if text == button_text:
			text = ""
			InputMap.action_erase_events(action)


func get_action_bind_key():
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			var key = OS.get_keycode_string(event.physical_keycode)
			text = key
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					text = "LMB"
				MOUSE_BUTTON_RIGHT:
					text = "RMB"
				MOUSE_BUTTON_WHEEL_UP:
					text = "MOUSE WHEEL UP"
				MOUSE_BUTTON_WHEEL_DOWN:
					text = "MOUSE WHEEL DOWN"
			break


func _on_pressed() -> void:

	if input_remap_manager.check_is_other_button_already_pressed():
		return
	text = "Waiting..."
	input_remap_manager.start_input_remap(self)
	
