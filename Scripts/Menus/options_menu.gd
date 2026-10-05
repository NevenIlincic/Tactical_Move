class_name OptionsMenu extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var back_button: NavigationButton = $Back_Button
@onready var inputs_tab_button: TabButton = $Tabs/Inputs_Tab_Button
@onready var audio_tab_button: TabButton = $Tabs/Audio_Tab_Button
@onready var video_tab_button: TabButton = $Tabs/Video_Tab_Button
@onready var options_saved_label: Label = $Options_Saved_Label

#MENUS
@onready var inputs_menu: Node2D = $Inputs_Menu
@onready var audio_menu: Node2D = $Audio_Menu
@onready var video_menu: VideoMenu = $Video_Menu

#AUDIO SLIDERS
@onready var control: AudioSlider = $Audio_Menu/ScrollContainer/VBoxContainer/Control
@onready var control_2: AudioSlider = $Audio_Menu/ScrollContainer/VBoxContainer/Control2
@onready var control_3: AudioSlider = $Audio_Menu/ScrollContainer/VBoxContainer/Control3
@onready var control_4: AudioSlider = $Audio_Menu/ScrollContainer/VBoxContainer/Control4

var audio_sliders: Array[AudioSlider] = []
var current_tab_opened: String = "INPUTS_TAB"
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
	
	audio_sliders.append(control)
	audio_sliders.append(control_2)
	audio_sliders.append(control_3)
	audio_sliders.append(control_4)
func connect_to_signals():
	inputs_tab_button.inputs_button.pressed.connect(_on_inputs_tab_button_pressed)
	audio_tab_button.inputs_button.pressed.connect(_on_audio_tab_button_pressed)
	video_tab_button.inputs_button.pressed.connect(_on_video_tab_button_pressed)
	Signals.options_saved.connect(_on_options_saved)

func play_appear_animation():
	visible = true
	animation_player.play("Tabs_Appear_Animation")

func reset_appear_animation():
	animation_player.stop()
	animation_player.seek(0)

func _unhandled_input(event: InputEvent) -> void:
	input_remap_manager._unhandled_input(event)

func _on_inputs_tab_button_pressed():
	current_tab_opened = "INPUTS_TAB"
	inputs_menu.visible = true
	audio_menu.visible = false
	video_menu.visible = false
	for button: InputButton in input_buttons:
		button.get_action_bind_key()
func _on_audio_tab_button_pressed():
	current_tab_opened = "AUDIO_TAB"
	inputs_menu.visible = false
	audio_menu.visible = true
	video_menu.visible = false
	for audio_slider: AudioSlider in audio_sliders:
		audio_slider.set_slider_value()
func _on_video_tab_button_pressed():
	current_tab_opened = "VIDEO_TAB"
	inputs_menu.visible = false
	audio_menu.visible = false
	video_menu.visible = true
	video_menu.set_initial_values()


func _on_options_saved(message: String):
	options_saved_label.text = message
	options_saved_label.visible = true
	get_tree().create_timer(2.0).timeout.connect(
		func():
			options_saved_label.visible = false
	)

func check_tab_to_open():
	if current_tab_opened == "INPUTS_TAB":
		_on_inputs_tab_button_pressed()
	elif current_tab_opened == "AUDIO_TAB":
		_on_audio_tab_button_pressed()
	else:
		_on_video_tab_button_pressed()
