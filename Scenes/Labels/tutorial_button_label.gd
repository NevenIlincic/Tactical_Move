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



func _ready() -> void:
	get_action_bind_key()
	dialog_label.text = dialog_text
	start_pulse_effect()
	

func _unhandled_input(event: InputEvent) -> void:
	if not is_activated_by_pressing:
		if Input.is_action_just_released(key_action):
			key_action_released.emit()
	else:
		if Input.is_action_just_pressed(key_action):
			key_action_released.emit()

func get_action_bind_key():
	var events = InputMap.action_get_events(key_action)
	for event in events:
		if event is InputEventKey:
			var key = OS.get_keycode_string(event.physical_keycode)
			action_label.text = key
		elif event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					action_label.text = "LMB"
				MOUSE_BUTTON_RIGHT:
					action_label.text = "RMB"
				MOUSE_BUTTON_WHEEL_UP:
					action_label.text = "MOUSE WHEEL UP"
				MOUSE_BUTTON_WHEEL_DOWN:
					action_label.text = "MOUSE WHEEL DOWN"
				MOUSE_BUTTON_MIDDLE:
					action_label.text = "MMB"
			break

func start_pulse_effect():
	var tween = create_tween().set_loops()
	
	tween.tween_property(action_label, "scale", Vector2(1.05, 1.05), 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	tween.tween_property(action_label, "scale", Vector2(1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
