extends Node2D

@onready var inputs_tab: Node2D = $Inputs_Tab
@onready var audio_tab: Node2D = $Audio_Tab
@onready var video_tab: Node2D = $Video_Tab

func _ready() -> void:
	add_buttons_to_buttons_group()

func add_buttons_to_buttons_group():
	var tabs_button_group: ButtonGroup = ButtonGroup.new()
	var input_tab_button: TextureButton = inputs_tab.get_child(0)
	var audio_tab_button: TextureButton = audio_tab.get_child(0)
	var video_tab_button: TextureButton = video_tab.get_child(0)
	
	input_tab_button.button_group = tabs_button_group
	audio_tab_button.button_group = tabs_button_group
	video_tab_button.button_group = tabs_button_group
