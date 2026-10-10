class_name LevelSelectionButton extends Node2D

signal show_level_cover_image()
signal level_button_pressed()


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_rect: TextureRect = $Texture_Rect
@onready var label: Label = $Texture_Rect/Label

var is_animation_loop_finished: bool = false
var is_mouse_hovered: bool = false
@export var button_text: String

@export var level_cover_texture: CompressedTexture2D

#MOBILE DEVICES
@onready var mobile_level_button: Button = $Mobile_Level_Button

func _ready() -> void:
	label.text = button_text
	if OptionVariables.check_is_device_pc():
		mobile_level_button.visible = false

func _on_animation_loop_finished():
	if not is_mouse_hovered:
		is_animation_loop_finished = true
		animation_player.stop()
		animation_player.seek(0)
func _on_animation_loop_started():
	is_animation_loop_finished = false


func _on_texture_rect_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.05).set_ease(Tween.EASE_IN)
	animation_player.play("card_shine_effect")
	is_mouse_hovered = true
	AudioManager.play_button_hover_sound()
	if OptionVariables.check_is_device_pc():
		show_level_cover_image.emit()


func _on_texture_rect_mouse_exited() -> void:
	is_mouse_hovered = false
	var tween: Tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.05).set_ease(Tween.EASE_IN)
	


func _on_texture_rect_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			AudioManager.play_upgrade_sound()
			match button_text:
				"Training Course":
					await _on_button_pressed()
					get_tree().change_scene_to_file("res://Scenes/Levels/Training_Course.tscn")
				"Beach":
					await _on_button_pressed()
					get_tree().change_scene_to_file("res://Scenes/Levels/Beach.tscn")
				"House":
					await _on_button_pressed()
					get_tree().change_scene_to_file("res://Scenes/Levels/House.tscn")
				"Parking Lot":
					await _on_button_pressed()
					get_tree().change_scene_to_file("res://Scenes/Levels/Parking_Lot.tscn")
				"Park":
					await _on_button_pressed()
					get_tree().change_scene_to_file("res://Scenes/Levels/Park.tscn")
				#"START":
					#transition_to_level_selection_screen.emit()
					##get_tree().change_scene_to_file("res://Scenes/Test_Scene.tscn")
				#"OPTIONS":
					#transition_to_options_screen.emit()
					##get_tree().change_scene_to_file("res://Scenes/Menu/Options_Menu.tscn")
				#"BACK":
					#transition_to_main_screen.emit()


func _on_button_pressed():
	level_button_pressed.emit()
	await get_tree().create_timer(0.5).timeout

func _on_mobile_level_button_pressed() -> void:
	show_level_cover_image.emit()
