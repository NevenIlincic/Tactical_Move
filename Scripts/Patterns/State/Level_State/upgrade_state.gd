class_name UpgradeState extends State

var level: Level
var alive_players: Dictionary
var upgrade_menu: UpgradeMenu

func _init(data: Array):
	level = data[0]
	upgrade_menu = level.upgrade_menu
	alive_players = level.get_alive_players()
	upgrade_menu.set_alive_players(alive_players)
	upgrade_menu.show_upgrade_menu()
	level.current_state_label.text = "UPGRADE STATE"


func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("switch_to_move_state"):
		upgrade_menu.hide_upgrade_menu()
		level.set_level_state(PlayerSetMoveState.new([level]))
		return
	if Input.is_action_just_pressed("switch_to_preparation_state"):
		upgrade_menu.hide_upgrade_menu()
		level.set_level_state(PreparationState.new([level]))
		return
	
	if Input.is_action_just_pressed("move_confirm"):
		if level.check_can_do_action():
			upgrade_menu.hide_upgrade_menu()
			level.set_level_state(ActionState.new([level]))
		
func _physics_process(_delta: float):
	pass
