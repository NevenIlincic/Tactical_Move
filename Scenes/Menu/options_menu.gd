extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

####
var input_remap_manager: InputRemapManager
var input_buttons: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_remap_manager = InputRemapManager.new()
	animation_player.play("Tabs_Appear_Animation")
	input_buttons = get_tree().get_nodes_in_group("input_button")
	for button: InputButton in input_buttons:
		button.set_input_remap_manager(input_remap_manager)
		input_remap_manager.input_key_changed.connect(button.check_is_same_action_key_bind)
	print(input_buttons.size())
	get_initial_button_inputs()
	
func get_initial_button_inputs():
	pass
	#input_remap_manager.get_initial_action_bind_key(player_look_at_button, "rotate_player")
	#input_remap_manager.get_initial_action_bind_key(player_look_at_reset_button, "reset_look_at_path")
	#input_remap_manager.get_initial_action_bind_key(player_look_at_after_move_button, "rotate_player_after_move")
	#input_remap_manager.get_initial_action_bind_key(player_look_at_after_move_reset_button, "reset_rotate_player_after_move")
	#input_remap_manager.get_initial_action_bind_key(player_draw_path_button, "drawing")
	#input_remap_manager.get_initial_action_bind_key(player_draw_path_reset_button, "reset_path")
	#input_remap_manager.get_initial_action_bind_key(strategy_selection_button, "popup")
	#input_remap_manager.get_initial_action_bind_key(upgrade_menu_button, "upgrade_menu")
	#input_remap_manager.get_initial_action_bind_key(toggle_medic_healing_button, "healing")
#
	##CAMERA
	#input_remap_manager.get_initial_action_bind_key(camera_zoom_in_button, "zoom_camera_in")
	#input_remap_manager.get_initial_action_bind_key(camera_zoom_out_button, "zoom_camera_out")
	#input_remap_manager.get_initial_action_bind_key(camera_move_button, "camera_drag")


func _unhandled_input(event: InputEvent) -> void:
	input_remap_manager._unhandled_input(event)
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://Scenes/Menu/Main_Menu.tscn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
