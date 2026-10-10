class_name VideoMenu extends Node2D

@onready var ray_cast_number_input: Control = $Inputs_Scroll_Container/GridContainer/Ray_Cast_Number_Input
@onready var dummy_8: Control = $Inputs_Scroll_Container/GridContainer/Dummy_8
@onready var edge_iterations_number: Control = $Inputs_Scroll_Container/GridContainer/Edge_Iterations_Number
@onready var dummy_3: Control = $Inputs_Scroll_Container/GridContainer/Dummy_3

#OPTION BUTTONS
@onready var fps_option_button: OptionButton = $Inputs_Scroll_Container/GridContainer/Show_FPS_Input/FPS_Option_Button
@onready var max_fps_spin_box: SpinBox = $Inputs_Scroll_Container/GridContainer/Max_FPS_Input/Max_FPS_Spin_Box
@onready var quality_option_button: OptionButton = $Inputs_Scroll_Container/GridContainer/Quality_Input/Quality_Option_Button
@onready var vision_indicator_option_button: OptionButton = $Inputs_Scroll_Container/GridContainer/Player_Vision_Indicator/Vision_Indicator_Option_Button
@onready var ray_cast_spin_box: SpinBox = $Inputs_Scroll_Container/GridContainer/Ray_Cast_Number_Input/Ray_Cast_Number/Ray_Cast_Spin_Box
@onready var edge_iterations_spin_box: SpinBox = $Inputs_Scroll_Container/GridContainer/Edge_Iterations_Number/Edge_Iterations_Spin_Box
@onready var gun_blast_effect_option_button: OptionButton = $Inputs_Scroll_Container/GridContainer/Gun_Blast_Effect/Gun_Blast_Effect_Option_Button

@onready var tooltip_label: Label = $Tooltip_Label

var style: StyleBoxFlat
var activated_tooltips: Dictionary = {}


func _ready() -> void:
	create_label_tooltip_style()
	
func create_label_tooltip_style():
	style = StyleBoxFlat.new()
	
	style.bg_color = Color("#3b3b3cc2")      
	
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	
func _on_tooltip_activated(activated_label: CustomTooltip, mouse_global_position: Vector2i):
	if activated_tooltips.has(activated_label.option):
		return
	activated_tooltips[activated_label.option] = true
	var label: Label = Label.new()
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	label.add_theme_stylebox_override("normal", style)
	label.text = activated_label.tooltip_text
	add_child(label)
	label.global_position = mouse_global_position + Vector2i(20, 0)
	await get_tree().create_timer(2.0).timeout.connect(func():
		activated_tooltips.erase(activated_label.option)
		label.queue_free()
		)

func set_initial_values():
	var is_advanced_options_visible: bool = true if OptionVariables.vision_type == OptionVariables.VisionType.ADVANCED else false
	hide_show_advanced_vision_inputs(is_advanced_options_visible)
	quality_option_button.selected = 0 if get_tree().root.content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS else 1
	fps_option_button.selected = 1 if OptionVariables.show_fps else 0
	max_fps_spin_box.value = 999 if Engine.max_fps == 0 else OptionVariables.fps_limit
	vision_indicator_option_button.selected = 0 if OptionVariables.vision_type == OptionVariables.VisionType.BASIC else 1
	ray_cast_spin_box.value = OptionVariables.ray_count
	edge_iterations_spin_box.value = OptionVariables.edge_precision_iterations
	gun_blast_effect_option_button.selected = 1 if OptionVariables.is_blast_effect_enabled else 0
func _on_ray_cast_spin_box_value_changed(value: float) -> void:
	OptionVariables.ray_count = int(value)


func _on_edge_iterations_spin_box_value_changed(value: float) -> void:
	OptionVariables.edge_precision_iterations = int(value)


func _on_quality_option_button_item_selected(index: int) -> void:
	match index:
		0:
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
			OptionVariables.option_values["Video"]["quality"] = "NORMAL"

		1:
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			OptionVariables.option_values["Video"]["quality"] = "WORSE"

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


func _on_gun_blast_effect_option_button_item_selected(index: int) -> void:
	match index:
		0: #OFF
			OptionVariables.is_blast_effect_enabled = false
		1:
			OptionVariables.is_blast_effect_enabled = true


func _on_vision_indicator_option_button_item_selected(index: int) -> void:
	match index:
		0:
			OptionVariables.vision_type = OptionVariables.VisionType.BASIC
			hide_show_advanced_vision_inputs(false)
		1:
			OptionVariables.vision_type = OptionVariables.VisionType.ADVANCED
			hide_show_advanced_vision_inputs(true)
