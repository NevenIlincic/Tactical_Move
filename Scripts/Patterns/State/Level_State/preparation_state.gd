class_name PreparationState extends State

var level: Level

func _init(data: Array):
	level = data[0]
	level.current_state_label.text = "OBSERVATION STATE"
	level.radial_menu.id_pressed.connect(_on_popup_menu_item_pressed)

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("upgrade_menu"):
		level.set_level_state(UpgradeState.new([level]))
		return
	if Input.is_action_just_pressed("switch_to_move_state"):
		level.set_level_state(PlayerSetMoveState.new([level]))
		return
	if Input.is_action_just_pressed("move_confirm"):
		if level.check_can_do_action():
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
