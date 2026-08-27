extends Node2D

var input_remap_manager: InputRemapManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_remap_manager = InputRemapManager.new()
	

func _unhandled_input(event: InputEvent) -> void:
	input_remap_manager._unhandled_input(event)
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://Scenes/Menu/Main_Menu.tscn")
