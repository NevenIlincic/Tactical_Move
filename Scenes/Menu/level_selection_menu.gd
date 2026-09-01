class_name LevelSelectionMenu extends Node2D

@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer

@onready var level_selection_back_button: NavigationButton = $Level_Selection_Back_Button
@onready var level_cover: Sprite2D = $Level_Cover

func _ready() -> void:
	connect_to_signals()
	
func connect_to_signals():
	for control_node: Control in v_box_container.get_children():
		var button: LevelSelectionButton = control_node.get_child(0)
		button.show_level_cover_image.connect(_on_button_hovered.bind(button))

func _on_button_hovered(button: LevelSelectionButton):
	level_cover.texture = button.level_cover_texture
