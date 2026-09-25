extends Node2D

@onready var ray_cast_number_input: Control = $Inputs_Scroll_Container/GridContainer/Ray_Cast_Number_Input
@onready var dummy_8: Control = $Inputs_Scroll_Container/GridContainer/Dummy_8
@onready var edge_iterations_number: Control = $Inputs_Scroll_Container/GridContainer/Edge_Iterations_Number
@onready var dummy_3: Control = $Inputs_Scroll_Container/GridContainer/Dummy_3

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			OptionVariables.vision_type = OptionVariables.VisionType.BASIC
			hide_show_advanced_vision_inputs(false)
		1:
			OptionVariables.vision_type = OptionVariables.VisionType.ADVANCED
			hide_show_advanced_vision_inputs(true)

func _on_ray_cast_spin_box_value_changed(value: float) -> void:
	OptionVariables.ray_count = int(value)


func _on_edge_iterations_spin_box_value_changed(value: float) -> void:
	OptionVariables.edge_precision_iterations = int(value)


func _on_quality_option_button_item_selected(index: int) -> void:
	match index:
		0:
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

		1:
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			
func _on_fps_option_button_item_selected(index: int) -> void:
	match index:
		0: #OFF
			OptionVariables.show_fps = false
		1:
			OptionVariables.show_fps = true
	
func _on_max_fps_spin_box_value_changed(value: float) -> void:
	OptionVariables.fps_limit = value

func hide_show_advanced_vision_inputs(is_shown: bool):
	ray_cast_number_input.visible = is_shown
	dummy_8.visible = is_shown
	edge_iterations_number.visible = is_shown
	dummy_3.visible = is_shown
