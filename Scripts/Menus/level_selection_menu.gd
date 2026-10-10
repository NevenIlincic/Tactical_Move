class_name LevelSelectionMenu extends Node2D

const ACHIEVEMENT_LABEL = preload("uid://dnkukugw6ahs7")

@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer
#@onready var achievements_grid_container: GridContainer = $ScrollContainer2/Achievements_Grid_Container
#CONTAINERS
@onready var achievements_grid_container: GridContainer = $Achievements_Scroll_Container/MarginContainer/Achievements_Grid_Container
@onready var margin_container: MarginContainer = $Achievements_Scroll_Container/MarginContainer
@onready var achievements_scroll_container: ScrollContainer = $Achievements_Scroll_Container

@onready var level_selection_back_button: NavigationButton = $Level_Selection_Back_Button
@onready var level_cover: Sprite2D = $Level_Cover

@onready var loading_label: Label = $Loading_Label

func _ready() -> void:
	connect_to_signals()
	level_selection_back_button.appear_effect_animation_player.play("appear_animation")
	set_up_achievements_scroll_container()
func connect_to_signals():
	for control_node: Control in v_box_container.get_children():
		var button: LevelSelectionButton = control_node.get_child(0)
		button.show_level_cover_image.connect(_on_button_hovered.bind(button))
		button.level_button_pressed.connect(_on_level_button_pressed)
func _on_button_hovered(button: LevelSelectionButton):
	level_cover.texture = button.level_cover_texture
	clear_achievements_grid()
	display_level_achievements(button.button_text)

func display_level_achievements(level_name: String):
	if Achievements.achievements.has(level_name):
		for achievement_text in Achievements.achievements[level_name]:
			var achievement_label: AchievementLabel = ACHIEVEMENT_LABEL.instantiate()
			achievements_grid_container.add_child(achievement_label)
			achievement_label.initialize_achivement_node(level_name, achievement_text)
	
	var control_1: Control = Control.new()
	var control_2: Control = Control.new()
	achievements_grid_container.add_child(control_1)
	achievements_grid_container.add_child(control_2)

	
func clear_achievements_grid():
	var level_achivements: Array = achievements_grid_container.get_children()
	for achivement_node in level_achivements:
		achievements_grid_container.remove_child(achivement_node)

func set_up_achievements_scroll_container():
	if OptionVariables.check_is_device_pc():
		achievements_scroll_container.layout_direction = Control.LAYOUT_DIRECTION_LTR
		achievements_scroll_container.position = Vector2(80.0, 440.0)
	else:
		achievements_scroll_container.position = Vector2(48.0, 440.0)
		margin_container.add_theme_constant_override("margin_left", 15)

func _on_level_button_pressed():
	loading_label.visible = true
	for control_node: Control in v_box_container.get_children():
		var button: LevelSelectionButton = control_node.get_child(0)
		if button.show_level_cover_image.is_connected(_on_button_hovered.bind(button)):
			button.show_level_cover_image.disconnect(_on_button_hovered.bind(button))
		if button.level_button_pressed.is_connected(_on_level_button_pressed):
			button.level_button_pressed.disconnect(_on_level_button_pressed)
	
