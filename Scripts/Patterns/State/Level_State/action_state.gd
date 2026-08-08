class_name ActionState extends State

var level: Level
var vision_manager: VisionManager

var initial_num_alive_enemies: int 
var num_finished_moves: int
var alive_soldiers: Dictionary

func _init(data: Array):
	level = data[0]
	alive_soldiers = level.get_alive_soldiers()
	num_finished_moves = 0

	vision_manager = VisionManager.new()
	
	for player: Soldier in alive_soldiers.keys():	
		player.do_actions()
	
func _unhandled_input(event: InputEvent):
	pass

func _physics_process(delta: float) -> void:
	vision_manager.handle_enemy_visibility(delta)
	var all_players_finished_moves: bool = true
	
	check_for_deletion()
			
	for player: Soldier in alive_soldiers.keys():
		player.do_while_action(delta)
		#if len(alive_soldiers) == 1:
			#print(player.is_soldier_walking(), " ", player.has_enemies_in_sight())
		if not player.is_in_finished_state():
			all_players_finished_moves = false
			
	if all_players_finished_moves:
		level.set_level_state(PlayerSetMoveState.new([level]))

func check_for_deletion():
	for player in alive_soldiers.keys():
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			alive_soldiers.erase(player)
