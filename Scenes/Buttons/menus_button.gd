extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_rect: TextureRect = $Texture_Rect
@onready var label: Label = $Texture_Rect/Label

var is_animation_loop_finished: bool = false
var is_mouse_hovered: bool = false
@export var button_text: String

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
	tween.tween_property(texture_rect, "scale", Vector2(0.9, 0.5), 0.05).set_ease(Tween.EASE_IN)
	animation_player.play("card_shine_effect")
	is_mouse_hovered = true


func _on_texture_rect_mouse_exited() -> void:
	is_mouse_hovered = false
	var tween: Tween = create_tween()
	tween.tween_property(texture_rect, "scale", Vector2(1.0, 0.5), 0.05).set_ease(Tween.EASE_OUT)


func _on_texture_rect_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			match button_text:
				"START":
					get_tree().change_scene_to_file("res://Scenes/Test_Scene.tscn")
