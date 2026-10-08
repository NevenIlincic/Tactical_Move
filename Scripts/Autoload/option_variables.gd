extends Node

enum RunningDevice{
	PC,
	MOBILE
}
var device: RunningDevice = RunningDevice.PC

func _ready() -> void:
	check_device_platform()

func check_is_device_pc() -> bool:
	return device == RunningDevice.PC

func check_device_platform() -> void:
	if OS.get_name() == "Web":
		var user_agent = JavaScriptBridge.eval("navigator.userAgent").to_lower()
		
		if "iphone" in user_agent or "ipad" in user_agent or "ipod" in user_agent:
			device = RunningDevice.MOBILE
		elif "android" in user_agent:
			device = RunningDevice.MOBILE
		else:
			device = RunningDevice.PC


#### VIDEO SETTINGS
#PLAYER VISION
signal vision_type_changed(new_vision_type: VisionType)
signal ray_cast_num_changed(new_value: int)
signal num_edge_precision_iterations_changed(new_value: int)

enum VisionType{
	BASIC,
	ADVANCED
}
var vision_type: VisionType = VisionType.ADVANCED:
	set(value):
		vision_type = value
		option_values["Video"]["vision_type"] = value
		vision_type_changed.emit(value)
var ray_count: int = 10:
	set(value):
		ray_count = value
		option_values["Video"]["ray_count"] = value
		ray_cast_num_changed.emit(value)
var edge_precision_iterations: int = 1:
	set(value):
		edge_precision_iterations = value
		option_values["Video"]["edge_precision_iterations"] = value
		num_edge_precision_iterations_changed.emit(value)
		
func check_is_advanced_vision_type() -> bool:
	return vision_type == VisionType.ADVANCED
	
### GENERAL
signal show_fps_changed(value: bool)

var show_fps: bool = false:
	set(value):
		show_fps = value
		option_values["Video"]["show_fps"] = value
		show_fps_changed.emit(value)
var fps_limit: float = 0:
	set(value):
		fps_limit = value
		option_values["Video"]["fps_limit"] = value
		Engine.max_fps = value

## EFFECTS
var is_blast_effect_enabled: bool = true:
	set(value):
		is_blast_effect_enabled = value
		option_values["Video"]["blast_effect_enabled"] = value

############### AUDIO SETTINGS
var option_values: Dictionary = {
	"Audio": {
			"Master": 100.0,
			"Background_Music": 100.0,
			"Effects": 100.0,
			"HUD_Effects": 100.0
			},
	"Video": {
			"quality": "NORMAL",
			"show_fps": false,
			"fps_limit": 999,
			"vision_type": vision_type,
			"ray_count": ray_count,
			"edge_precision_iterations": edge_precision_iterations,
			"blast_effect_enabled": is_blast_effect_enabled
			},
	"Inputs": {
			"move_confirm": "Space",
			"drawing": "Shift",
			"reset_path": "Q",
			"rotate_player": "RMB",
			"reset_look_at_path": "W",
			"rotate_player_after_move": "Z",
			"reset_rotate_player_after_move": "X",
			"camera_drag": "Ctrl",
			"upgrade_menu": 3,
			"popup": "P",
			"healing": "H",
			"zoom_camera_in": "MOUSE WHEEL UP",
			"zoom_camera_out": "MOUSE WHEEL DOWN",
			"switch_to_preparation_state": 1,
			"switch_to_move_state": 2,
			"pause_menu": "Escape",
			"reset_camera_position": "MMB",
			"next_tutorial_step": "Enter",
			"select_player": "LMB"
	}
}

func set_values():
	if Bridge.platform.is_audio_enabled:
		_set_audio_values()
	_set_video_values()
	_set_input_values()

func _set_audio_values():
	for audio_bus: String in option_values["Audio"].keys():
		var bus_value: float = option_values["Audio"][audio_bus]
		var linear_value: float = bus_value / 100.0
		var db_value: float = linear_to_db(linear_value)
		var bus_index = AudioServer.get_bus_index(audio_bus)
		AudioServer.set_bus_volume_db(bus_index, db_value)
		AudioServer.set_bus_mute(bus_index, linear_value == 0)

func _set_input_values():
	var input_values: Dictionary = option_values["Inputs"]
	register_custom_inputs(input_values)


func _set_video_values():
	var video_values: Dictionary = option_values["Video"]
	var input_values: Dictionary = option_values["Inputs"]
	if video_values["quality"] == "NORMAL":
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	else:
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	
	show_fps = video_values["show_fps"]
	fps_limit = video_values["fps_limit"]
	vision_type = video_values["vision_type"] as VisionType
	ray_count = video_values["ray_count"]
	edge_precision_iterations = video_values["edge_precision_iterations"]
	is_blast_effect_enabled = video_values["blast_effect_enabled"]
func register_custom_inputs(data: Dictionary) -> void:
	for action_name in data.keys():
		var raw_value = data[action_name]
		if raw_value is String and raw_value == "":
			continue
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		else:
			InputMap.action_erase_events(action_name)
		
		var event: InputEvent = create_input_event(raw_value)
		
		if event:
			InputMap.action_add_event(action_name, event)

func create_input_event(value) -> InputEvent:
	if typeof(value) == TYPE_STRING:
		var val_upper = value.strip_edges().to_upper()
		match val_upper:
			"LMB":
				var mb = InputEventMouseButton.new()
				mb.button_index = MOUSE_BUTTON_LEFT
				return mb
			"RMB":
				var mb = InputEventMouseButton.new()
				mb.button_index = MOUSE_BUTTON_RIGHT
				return mb
			"MMB":
				var mb = InputEventMouseButton.new()
				mb.button_index = MOUSE_BUTTON_MIDDLE
				return mb
			"MOUSE WHEEL UP":
				var mb = InputEventMouseButton.new()
				mb.button_index = MOUSE_BUTTON_WHEEL_UP
				return mb
			"MOUSE WHEEL DOWN":
				var mb = InputEventMouseButton.new()
				mb.button_index = MOUSE_BUTTON_WHEEL_DOWN
				return mb

		var keycode = OS.find_keycode_from_string(value)
		if keycode != KEY_NONE:
			var key_event = InputEventKey.new()
			key_event.keycode = keycode
			return key_event

	elif typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		var key_event = InputEventKey.new()
		key_event.keycode = OS.find_keycode_from_string(str(int(value)))
		return key_event

	push_error("Failed to parse input value: %s" % str(value))
	return null

func check_key_exists(action: String, value: String):
	for key in option_values["Inputs"].keys():
		if key == action:
			continue
		if str(int(option_values["Inputs"][key])) == value:
			option_values["Inputs"][key] = ""
