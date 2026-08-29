class_name PreparationState extends State

var level: Level

func _init(data: Array):
	level = data[0]
	level.current_state_label.text = "OBSERVATION STATE"

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
func _physics_process(_delta: float):
	pass
