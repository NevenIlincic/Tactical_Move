extends Node2D

@onready var inputs_tab_button: TabButton = $Inputs_Tab_Button
@onready var audio_tab_button: TabButton = $Audio_Tab_Button
@onready var video_tab_button: TabButton = $Video_Tab_Button

func _ready() -> void:
	add_buttons_to_buttons_group()

func add_buttons_to_buttons_group():
	var tabs_button_group: ButtonGroup = ButtonGroup.new()
	var input_button: TextureButton = inputs_tab_button.get_child(0)
	var audio_button: TextureButton = audio_tab_button.get_child(0)
	var video_button: TextureButton = video_tab_button.get_child(0)
	
	input_button.button_group = tabs_button_group
	audio_button.button_group = tabs_button_group
	video_button.button_group = tabs_button_group
