class_name PreparationState extends State

var level: Level

func _init(data: Array):
	level = data[0]
	level.prepare_state_label.visible = true

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("upgrade_menu"):
		level.prepare_state_label.visible = false
		level.set_level_state(UpgradeState.new([level]))
	if Input.is_action_just_pressed("move_confirm"):
		level.prepare_state_label.visible = false
		level.set_level_state(PlayerSetMoveState.new([level]))
func _physics_process(_delta: float):
	pass
