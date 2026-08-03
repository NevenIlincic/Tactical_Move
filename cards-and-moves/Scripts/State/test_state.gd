class_name TestState extends State

var level: Level

func _init(data: Array):
	level = data[0]
		
func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("move_state"):
		print("NOVO STANJE!")
		level.set_level_state(PlayerSetMoveState.new([level]))
