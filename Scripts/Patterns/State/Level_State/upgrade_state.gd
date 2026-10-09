class_name UpgradeState extends State

var alive_players: Dictionary
var upgrade_menu: UpgradeMenu

func _init(data: Array):
	level = data[0]
	upgrade_menu = level.upgrade_menu
	alive_players = level.get_alive_players()
	upgrade_menu.set_alive_players(alive_players)
	upgrade_menu.show_upgrade_menu()
	level.current_state_label.text = "UPGRADE STATE"
	
	if not OptionVariables.check_is_device_pc():
		connect_to_mobile_signals()
		level.mobile_move_state_button.visible = false
		level.mobile_observation_state_button.visible = false
		level.controller_button.visible = false
		level.mobile_pause_button.visible = false
		level.mobile_strategy_button.visible = false
		level.mobile_action_button.visible = false
		
		level.mobile_draw_path_button.visible = false
		level.mobile_reset_path_button.visible = false
		level.mobile_point_to_look_while_moving_button.visible = false
		level.mobile_reset_point_to_look_while_moving_button.visible = false
		level.mobile_point_to_look_after_move_button.visible = false
		level.mobile_reset_point_to_look_after_move_button.visible = false

	
	level.can_manipulate_camera_signal.emit(true)
func connect_to_mobile_signals():
	connect_to_signals_extra()
	level.upgrade_button_pressed_mobile.connect(_on_upgrade_button_pressed_mobile)
	
	
func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("switch_to_move_state"):
		upgrade_menu.hide_upgrade_menu()
		level.controller_button.visible = true
		level.set_level_state(PlayerSetMoveState.new([level]))
		return
	if Input.is_action_just_pressed("switch_to_preparation_state"):
		upgrade_menu.hide_upgrade_menu()
		level.controller_button.visible = true
		level.set_level_state(PreparationState.new([level]))
		return
	
	if Input.is_action_just_pressed("move_confirm"):
		if level.check_can_do_action():
			upgrade_menu.hide_upgrade_menu()
			level.set_level_state(ActionState.new([level]))
		
func update(_delta: float):
	pass

#MOBILE
func _on_upgrade_button_pressed_mobile():
	disconnect_from_signals()
	upgrade_menu.hide_upgrade_menu()
	level.controller_button.visible = true
	level.mobile_pause_button.visible = true
	level.set_level_state(PreparationState.new([level]))

func disconnect_from_signals():
	if level.upgrade_button_pressed_mobile.is_connected(_on_upgrade_button_pressed_mobile):
		level.upgrade_button_pressed_mobile.disconnect(_on_upgrade_button_pressed_mobile)
