extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

####
var input_remap_manager: InputRemapManager
var input_buttons: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_remap_manager = InputRemapManager.new()
	animation_player.play("Tabs_Appear_Animation")
	input_buttons = get_tree().get_nodes_in_group("input_button")
	for button: InputButton in input_buttons:
		button.set_input_remap_manager(input_remap_manager)
		input_remap_manager.input_key_changed.connect(button.check_is_same_action_key_bind)
	
func _unhandled_input(event: InputEvent) -> void:
	input_remap_manager._unhandled_input(event)
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://Scenes/Menu/Main_Menu.tscn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
