class_name TutorialTextDialog extends Node2D

@export var key_action: String
@export var dialog_text: String
@export var appearing_order: int 
@export var action_key_exists: bool = true
@export var is_activated_by_pressing: bool = false

@onready var texture_rect: TextureRect = $TextureRect
@onready var h_box_container: HBoxContainer = $TextureRect/HBoxContainer

#LABELS
@onready var action_label: Label = $TextureRect/HBoxContainer/Action_Label
@onready var dialog_label: Label = $TextureRect/HBoxContainer/Dialog_Label

signal key_action_pressed()
signal key_action_released()

var button_textures: Dictionary = {
	"drawing": preload("uid://rn3tv1uo8xo1"),
	"reset_path": preload("uid://vffni4l4q3cs"),
	"rotate_player": preload("uid://cgx3x57yjdju7"),
	"reset_look_at_path": preload("uid://cgx3x57yjdju7"),
	"rotate_player_after_move": preload("uid://bq3737tfxvbx5"),
	"reset_rotate_player_after_move": preload("uid://dgy2b51ar205t"),
	"upgrade_menu": preload("uid://dg1lgkghotkmu"),
	"move_confirm": preload("uid://cqkb0dm6dgh1d"),
	"healing": preload("uid://bf76fqclkuigg"),
	"popup": preload("uid://boyruiqtblehv"),
	"switch_to_preparation_state": preload("uid://bubrqq711mt3u"),
	"switch_to_move_state": preload("uid://u4snu2wiae1p"),
	"pause_menu": preload("uid://dbepwj2v1an3"),
	"reset_camera_position": preload("uid://culr0obif7v8f")
	
}

@onready var mobile_action_texture_rect: TextureRect = $TextureRect/HBoxContainer/Mobile_Action_Texture_Rect

func _ready() -> void:
	get_action_bind_key()
	dialog_label.text = dialog_text
	start_pulse_effect()
	if not OptionVariables.check_is_device_pc():
		action_label.visible = false
		mobile_action_texture_rect.visible = true
		if button_textures.has(key_action):
			mobile_action_texture_rect.texture = button_textures[key_action]
		else:
			visible = false
func _unhandled_input(event: InputEvent) -> void:
	if not is_activated_by_pressing:
		if Input.is_action_just_released(key_action):
			key_action_released.emit()
	else:
		if Input.is_action_just_pressed(key_action):
			key_action_released.emit()

func get_action_bind_key():
	var value = OptionVariables.option_values["Inputs"][key_action]
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		action_label.text = str(int(value))
	else:
		action_label.text = OptionVariables.option_values["Inputs"][key_action]
	#var events = InputMap.action_get_events(key_action)
	#for event in events:
		#if event is InputEventKey:
			#var key = OS.get_keycode_string(event.physical_keycode)
			#action_label.text = key
		#elif event is InputEventMouseButton:
			#match event.button_index:
				#MOUSE_BUTTON_LEFT:
					#action_label.text = "LMB"
				#MOUSE_BUTTON_RIGHT:
					#action_label.text = "RMB"
				#MOUSE_BUTTON_WHEEL_UP:
					#action_label.text = "MOUSE WHEEL UP"
				#MOUSE_BUTTON_WHEEL_DOWN:
					#action_label.text = "MOUSE WHEEL DOWN"
				#MOUSE_BUTTON_MIDDLE:
					#action_label.text = "MMB"
			#break

func start_pulse_effect():
	var tween = create_tween().set_loops()
	
	var object_to_be_applied_on
	
	if OptionVariables.check_is_device_pc():
		object_to_be_applied_on = action_label
	else:
		object_to_be_applied_on = mobile_action_texture_rect
	tween.tween_property(object_to_be_applied_on, "scale", Vector2(1.05, 1.05), 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	tween.tween_property(object_to_be_applied_on, "scale", Vector2(1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
