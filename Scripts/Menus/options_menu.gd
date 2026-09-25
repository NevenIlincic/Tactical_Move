class_name OptionsMenu extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var back_button: NavigationButton = $Back_Button
@onready var inputs_tab_button: TabButton = $Tabs/Inputs_Tab_Button
@onready var audio_tab_button: TabButton = $Tabs/Audio_Tab_Button
@onready var video_tab_button: TabButton = $Tabs/Video_Tab_Button

#MENUS
@onready var inputs_menu: Node2D = $Inputs_Menu
@onready var audio_menu: Node2D = $Audio_Menu
@onready var video_menu: Node2D = $Video_Menu

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
	
	connect_to_signals()
	
func connect_to_signals():
	inputs_tab_button.inputs_button.pressed.connect(_on_inputs_tab_button_pressed)
	audio_tab_button.inputs_button.pressed.connect(_on_audio_tab_button_pressed)
	video_tab_button.inputs_button.pressed.connect(_on_video_tab_button_pressed)
func play_appear_animation():
	visible = true
	animation_player.play("Tabs_Appear_Animation")

func reset_appear_animation():
	animation_player.stop()
	animation_player.seek(0)

func _unhandled_input(event: InputEvent) -> void:
	input_remap_manager._unhandled_input(event)

func _on_inputs_tab_button_pressed():
	inputs_menu.visible = true
	audio_menu.visible = false
	video_menu.visible = false
func _on_audio_tab_button_pressed():
	inputs_menu.visible = false
	audio_menu.visible = true
	video_menu.visible = false
func _on_video_tab_button_pressed():
	inputs_menu.visible = false
	audio_menu.visible = false
	video_menu.visible = true


func _on_max_fps_spin_box_value_changed(value: float) -> void:
	pass # Replace with function body.
