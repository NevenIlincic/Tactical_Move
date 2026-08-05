class_name ActionState extends State

var level: Level
var vision_manager: VisionManager

var alive_enemies: Dictionary
var initial_num_alive_enemies: int 
var num_finished_moves: int
var alive_players: Dictionary

func _init(data: Array):
	level = data[0]
	alive_players = level.get_alive_players()
	initial_num_alive_enemies = len(alive_players)
	num_finished_moves = 0

	alive_enemies = level.get_alive_enemies()
	vision_manager = VisionManager.new(alive_enemies)
	
	for player: Player in alive_players.keys():
		player.do_actions()
	
func _unhandled_input(event: InputEvent):
	pass

func _physics_process(delta: float) -> void:
	vision_manager.handle_enemy_visibility(delta)
	var all_players_finished_moves: bool = true
	for player: Player in alive_players.keys():
		player.do_while_action(delta)
		if not player.is_in_finished_state():
			all_players_finished_moves = false
			
	if all_players_finished_moves:
		level.set_level_state(PlayerSetMoveState.new([level]))
	
