class_name OptionsMenu extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var back_button: NavigationButton = $Back_Button

####
var input_remap_manager: InputRemapManager
var input_buttons: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_remap_manager = InputRemapManager.new()
	input_buttons = get_tree().get_nodes_in_group("input_button")
	play_appear_animation()
	for button: InputButton in input_buttons:
		button.set_input_remap_manager(input_remap_manager)
		input_remap_manager.input_key_changed.connect(button.check_is_same_action_key_bind)

func play_appear_animation():
	animation_player.play("Tabs_Appear_Animation")

func reset_appear_animation():
	animation_player.stop()
	animation_player.seek(0)

func _unhandled_input(event: InputEvent) -> void:
	input_remap_manager._unhandled_input(event)
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://Scenes/Menu/Main_Menu.tscn")
