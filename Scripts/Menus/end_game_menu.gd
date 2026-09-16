class_name EndGameMenu extends Node2D

#LABELS
@onready var level_completed_failed_label: Label = $Level_Stats_Background/Level_Completed_Failed_Label
@onready var total_time_label: Label = $Level_Stats_Background/VBoxContainer/Total_Time_Label
@onready var enemies_killed_label: Label = $Level_Stats_Background/VBoxContainer/Enemies_Killed_Label
@onready var ally_soldiers_killed_label: Label = $Level_Stats_Background/VBoxContainer/Ally_Soldiers_Killed_Label

#BUTTONS
@onready var level_selection_button: NavigationButton = $Level_Selection_Button
@onready var retry_button: NavigationButton = $Retry_Button

func _ready() -> void:
	connect_to_signals()

func connect_to_signals():
	level_selection_button.transition_to_main_screen.connect(_on_level_selection_button_pressed)
	retry_button.retry_level.connect(_on_retry_button_pressed)
	
func show_end_game_menu(level: Level):
	get_tree().paused = true
	visible = true
	total_time_label.text = str("Total time: ", level.total_passed_minutes, "m ", level.total_passed_time_seconds, "s ", level.total_passed_time_millis, "ms" )
	enemies_killed_label.text = str("Enemies killed: ", level.get_num_killed_enemies(), "/", level.initial_num_enemies)
	ally_soldiers_killed_label.text = str("Ally soldiers killed: ", level.get_num_killed_players(), "/", level.initial_num_players)

func hide_end_game_menu():
	get_tree().paused = false
	visible = false

func on_level_failed(level: Level):
	show_end_game_menu(level)
	level_completed_failed_label.text = "LEVEL FAILED"
	level_selection_button.appear_effect_animation_player.play("appear_animation")
	retry_button.appear_effect_animation_player.play("appear_animation")
	
func on_level_completed(level: Level):
	retry_button.hide_button()
	show_end_game_menu(level)
	level_completed_failed_label.text = "LEVEL COMPLETED"
	level_selection_button.appear_effect_animation_player.play("appear_animation")
	
func _on_level_selection_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/Main_Menu.tscn")

func _on_retry_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
