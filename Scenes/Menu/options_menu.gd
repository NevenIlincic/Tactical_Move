extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

#INPUT BUTTONS
@onready var player_look_at_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Player_Look_At_Input/Player_Look_At_Button
@onready var player_look_at_reset_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Player_Look_At_Input_Reset/Player_Look_At_Reset_Button
@onready var player_look_at_after_move_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Player_Look_At_Input_After_Move/Player_Look_At_After_Move_Button
@onready var player_look_at_after_move_reset_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Player_Look_At_Input_After_Move_Reset/Player_Look_At_After_Move_Reset_Button
@onready var player_draw_path_reset_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Draw_Player_Path_Input_Reset/Player_Draw_Path_Reset_Button
@onready var player_draw_path_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Draw_Player_Path_Input/Player_Draw_Path_Button
@onready var strategy_selection_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Strategy_Selection_Input/Strategy_Selection_Button
@onready var upgrade_menu_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Upgrade_Menu_Input/Upgrade_Menu_Button
@onready var toggle_medic_healing_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Toggle_Medic_Healing_Input/Toggle_Medic_Healing_Button

#CAMERA
@onready var camera_zoom_in_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Camera_Zoom_In_Input/Camera_Zoom_In_Button
@onready var camera_zoom_out_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Camera_Zoom_Out_Input/Camera_Zoom_Out_Button
@onready var camera_move_button: Button = $Inputs_Menu/Inputs_Scroll_Container/GridContainer/Camera_Drag_Input/Camera_Move_Button

####

var input_remap_manager: InputRemapManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_remap_manager = InputRemapManager.new()
	animation_player.play("Tabs_Appear_Animation")
	get_initial_button_inputs()
	
func get_initial_button_inputs():
	input_remap_manager.get_initial_action_bind_key(player_look_at_button, "rotate_player")
	input_remap_manager.get_initial_action_bind_key(player_look_at_reset_button, "reset_look_at_path")
	input_remap_manager.get_initial_action_bind_key(player_look_at_after_move_button, "rotate_player_after_move")
	input_remap_manager.get_initial_action_bind_key(player_look_at_after_move_reset_button, "reset_rotate_player_after_move")
	input_remap_manager.get_initial_action_bind_key(player_draw_path_button, "drawing")
	input_remap_manager.get_initial_action_bind_key(player_draw_path_reset_button, "reset_path")
	input_remap_manager.get_initial_action_bind_key(strategy_selection_button, "popup")
	input_remap_manager.get_initial_action_bind_key(upgrade_menu_button, "upgrade_menu")
	input_remap_manager.get_initial_action_bind_key(toggle_medic_healing_button, "healing")

	#CAMERA
	input_remap_manager.get_initial_action_bind_key(camera_zoom_in_button, "zoom_camera_in")
	input_remap_manager.get_initial_action_bind_key(camera_zoom_out_button, "zoom_camera_out")
	input_remap_manager.get_initial_action_bind_key(camera_move_button, "camera_drag")


func _unhandled_input(event: InputEvent) -> void:
	input_remap_manager._unhandled_input(event)
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://Scenes/Menu/Main_Menu.tscn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
