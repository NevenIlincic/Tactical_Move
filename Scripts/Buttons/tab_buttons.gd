class_name TabButton extends Node2D

@onready var input_label: Label = $Input_Label
@onready var inputs_button: TextureButton = $Inputs_Button


func _ready() -> void:
	if input_label.text == "INPUTS":
		set_input_label_font_color(Color.LIGHT_SALMON)
		do_input_label_tween_scale(Vector2(1.2, 1.2))


func _on_inputs_button_toggled(toggled_on: bool) -> void:
	var scale_amount: Vector2
	var text_color: Color
	
	if toggled_on:
		scale_amount= Vector2(1.2, 1.2)
		text_color = Color.LIGHT_SALMON
		AudioManager.play_upgrade_sound()
	else:
		scale_amount = Vector2(1.0, 1.0)
		text_color = Color.WHITE
	
	set_input_label_font_color(text_color)
	do_input_label_tween_scale(scale_amount)

func set_input_label_font_color(color: Color):
	input_label.add_theme_color_override("font_color", color)
func do_input_label_tween_scale(scale_amount: Vector2):
	var tween: Tween = create_tween()
	tween.tween_property(input_label, "scale", scale_amount, 0.1).set_ease(Tween.EASE_IN)
