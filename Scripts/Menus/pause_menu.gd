class_name PauseMenu extends Node2D

@onready var options_menu: OptionsMenu = $OptionsMenu
@onready var resume_button: NavigationButton = $ResumeButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_pause_menu()
	connect_to_signals()
	options_menu.back_button.label.text = "LEAVE"

func connect_to_signals():
	options_menu.back_button.transition_to_main_screen.connect(_on_leave_button_pressed)
	resume_button.resume_game.connect(_on_resume_button_pressed)
	options_menu.animation_player.animation_finished.connect(_on_options_appear_animation_finished)
func hide_pause_menu():
	visible = false
	resume_button.visible = false
func show_pause_menu():
	get_tree().paused = true
	visible = true
	options_menu.play_appear_animation()

func _on_leave_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/Main_Menu.tscn")

func _on_resume_button_pressed():
	hide_pause_menu()
	get_tree().paused = false

func _on_options_appear_animation_finished(anim_name: String):
	if anim_name == "Tabs_Appear_Animation":
		resume_button.appear_effect_animation_player.play("appear_animation")
