extends Node2D

#CAMERA
@onready var camera: Camera2D = $Camera
@onready var option_camera_position: Marker2D = $Camera_Positions/Option_Camera_Position
@onready var main_menu_camera_position: Marker2D = $Camera_Positions/Main_Menu_Camera_Position
@onready var level_selection_menu_camera_position: Marker2D = $Camera_Positions/Level_Selection_Menu_Camera_Position

#MENUS
@onready var level_selection_menu: LevelSelectionMenu = $CanvasLayer/LevelSelectionMenu
@onready var options_menu: OptionsMenu = $CanvasLayer/OptionsMenu
####### BUTTONS
@onready var options_button: NavigationButton = $Options_Button
@onready var level_selection_button: NavigationButton = $Level_Selection_Button


###
#LIGHTS
@onready var main_menu_point_light_1: PointLight2D = $Main_Menu_Point_Light_1
@onready var main_menu_point_light_2: PointLight2D = $Main_Menu_Point_Light_2
########
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_to_signals()
	options_menu.visible = false


func connect_to_signals():
	level_selection_button.transition_to_level_selection_screen.connect(_on_level_selection_button_pressed)
	level_selection_menu.level_selection_back_button.transition_to_main_screen.connect(_on_main_screen_button_pressed)
	options_button.transition_to_options_screen.connect(_on_options_button_pressed)
	options_menu.back_button.transition_to_main_screen.connect(_on_main_screen_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_options_button_pressed():
	var tween: Tween = create_tween()
	tween.tween_property(camera, "global_position", option_camera_position.global_position, 0.4)
	tween.finished.connect(func():
		options_menu.visible = true
		options_menu.play_appear_animation()
		)

func _on_main_screen_button_pressed():
	options_menu.visible = false
	var tween: Tween = create_tween()
	tween.tween_property(camera, "global_position", main_menu_camera_position.global_position, 0.4)

func _on_level_selection_button_pressed():
	var tween: Tween = create_tween()
	tween.tween_property(camera, "global_position", level_selection_menu_camera_position.global_position, 0.4)
