class_name PreparationState extends State

var level: Level

func _init(data: Array):
	level = data[0]

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("upgrade_menu"):
		level.set_level_state(UpgradeState.new([level]))
	if Input.is_action_just_pressed("move_confirm"):
		level.set_level_state(PlayerSetMoveState.new([level]))
		
func _physics_process(delta: float):
	pass
