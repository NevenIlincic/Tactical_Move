@abstract
extends Node
class_name State

var level: Level

@abstract
func _init(data: Array);

@abstract
func _unhandled_input(event: InputEvent);

@abstract
func update(delta: float);

@abstract
func disconnect_from_signals();


func connect_to_signals_extra():
	level.pause_menu.reset_button_pressed.connect(_on_pause_menu_reset_button_pressed)

func _on_pause_menu_reset_button_pressed():
	if level.pause_menu.reset_button_pressed.is_connected(_on_pause_menu_reset_button_pressed):
		level.pause_menu.reset_button_pressed.disconnect(_on_pause_menu_reset_button_pressed)
	disconnect_from_signals()
	queue_free()
