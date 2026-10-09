class_name PreparationState extends State

var level: Level

func _init(data: Array):
	level = data[0]
	level.current_state_label.text = "OBSERVATION STATE"
	level.radial_menu.id_pressed.connect(_on_popup_menu_item_pressed)
	
	if not OptionVariables.check_is_device_pc():
		check_is_strategy_button_visible()
		connect_to_mobile_signals()
		level.mobile_move_state_button.visible = true
		level.mobile_observation_state_button.visible = false
		level.mobile_action_button.visible = true
		level.mobile_upgrade_menu_button.visible = true
		
		level.mobile_draw_path_button.visible = false
		level.mobile_reset_path_button.visible = false
		level.mobile_point_to_look_while_moving_button.visible = false
		level.mobile_reset_point_to_look_while_moving_button.visible = false
		level.mobile_point_to_look_after_move_button.visible = false

	level.can_manipulate_camera_signal.emit(true)
	
func connect_to_mobile_signals():
	level.action_button_pressed_mobile.connect(_on_action_button_pressed_mobile)
	level.upgrade_button_pressed_mobile.connect(_on_upgrade_button_pressed_mobile)
	level.move_state_button_pressed_mobile.connect(_on_move_state_button_pressed_mobile)
	level.strategy_button_pressed_mobile.connect(_on_strategy_button_pressed_mobile)
	PlayerSelectionManager.player_selection_changed_mobile.connect(_on_player_selected_mobile)
	PlayerSelectionManager.player_deselected.connect(_on_player_deselected_mobile)
	

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("upgrade_menu"):
		disconnect_from_signals()
		level.set_level_state(UpgradeState.new([level]))
		return
	if Input.is_action_just_pressed("switch_to_move_state"):
		disconnect_from_signals()
		level.set_level_state(PlayerSetMoveState.new([level]))
		return
	if Input.is_action_just_pressed("move_confirm"):
		if level.check_can_do_action():
			disconnect_from_signals()
			Signals.action_started.emit()
			level.set_level_state(ActionState.new([level]))
			return
	if Input.is_action_just_pressed("popup") and PlayerSelectionManager.selected_player and not PlayerSelectionManager.selected_player.is_killed:
		level.radial_menu.popup()
		return
func update(_delta: float):
	pass


func _on_popup_menu_item_pressed(item_id: int):
	match item_id:
		0:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.IGNORE)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(IgnoreEnemyStrategy.new())
		1:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.STOP_AND_SHOT_IN_PASSING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(StopShootPassingStrategy.new())
		2:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.STOP_AND_SHOT_FOLLOWING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(StopShootFollowingStrategy.new())
		3:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.MOVE_AND_SHOT_IN_PASSING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(MoveShootPassingStrategy.new())
		4:
			PlayerSelectionManager.selected_player.change_engagement_strategy(Player.EngagementRules.MOVE_AND_SHOT_FOLLOWING)
			#PlayerSelectionManager.selected_player.set_engagement_strategy(MoveShootFollowingStrategy.new())
	Signals.engagement_strategy_changed.emit(PlayerSelectionManager.selected_player)


#MOBILE
func _on_action_button_pressed_mobile():
	if level.check_can_do_action():
		disconnect_from_signals()
		Signals.action_started.emit()
		level.set_level_state(ActionState.new([level]))
		
func _on_upgrade_button_pressed_mobile():
	disconnect_from_signals()
	level.set_level_state(UpgradeState.new([level]))

func _on_move_state_button_pressed_mobile():
	disconnect_from_signals()
	level.set_level_state(PlayerSetMoveState.new([level]))

func _on_strategy_button_pressed_mobile():
	if PlayerSelectionManager.selected_player and not PlayerSelectionManager.selected_player.is_killed:
		level.radial_menu.popup()

func _on_player_selected_mobile():
	if PlayerSelectionManager.selected_player and not PlayerSelectionManager.selected_player.is_killed:
		level.mobile_strategy_button.visible = true

func _on_player_deselected_mobile(deselected_player: Player):
	level.mobile_strategy_button.visible = false
	level.mobile_reset_path_button.visible = false

func check_is_strategy_button_visible():
	if PlayerSelectionManager.selected_player and not PlayerSelectionManager.selected_player.is_killed:
		level.mobile_strategy_button.visible = true

func disconnect_from_signals():
	if level.action_button_pressed_mobile.is_connected(_on_action_button_pressed_mobile):
		level.action_button_pressed_mobile.disconnect(_on_action_button_pressed_mobile)
	if level.upgrade_button_pressed_mobile.is_connected(_on_upgrade_button_pressed_mobile):
		level.upgrade_button_pressed_mobile.disconnect(_on_upgrade_button_pressed_mobile)
	if level.move_state_button_pressed_mobile.is_connected(_on_move_state_button_pressed_mobile):
		level.move_state_button_pressed_mobile.disconnect(_on_move_state_button_pressed_mobile)
	if level.strategy_button_pressed_mobile.is_connected(_on_strategy_button_pressed_mobile):
		level.strategy_button_pressed_mobile.disconnect(_on_strategy_button_pressed_mobile)
	if PlayerSelectionManager.player_selection_changed_mobile.is_connected(_on_player_selected_mobile):
		PlayerSelectionManager.player_selection_changed_mobile.disconnect(_on_player_selected_mobile)
	if 	PlayerSelectionManager.player_deselected.is_connected(_on_player_deselected_mobile):
		PlayerSelectionManager.player_deselected.disconnect(_on_player_deselected_mobile)




	
