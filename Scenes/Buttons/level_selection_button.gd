class_name LevelSelectionButton extends Node2D

signal show_level_cover_image()


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_rect: TextureRect = $Texture_Rect
@onready var label: Label = $Texture_Rect/Label

var is_animation_loop_finished: bool = false
var is_mouse_hovered: bool = false
@export var button_text: String

@export var level_cover_texture: CompressedTexture2D

func _ready() -> void:
	label.text = button_text

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
	show_level_cover_image.emit()


func _on_texture_rect_mouse_exited() -> void:
	is_mouse_hovered = false
	var tween: Tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.05).set_ease(Tween.EASE_IN)
	


func _on_texture_rect_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			AudioManager.play_upgrade_sound()
			match button_text:
				"House":
					get_tree().change_scene_to_file("res://Scenes/Test_Scene.tscn")
				#"START":
					#transition_to_level_selection_screen.emit()
					##get_tree().change_scene_to_file("res://Scenes/Test_Scene.tscn")
				#"OPTIONS":
					#transition_to_options_screen.emit()
					##get_tree().change_scene_to_file("res://Scenes/Menu/Options_Menu.tscn")
				#"BACK":
					#transition_to_main_screen.emit()
