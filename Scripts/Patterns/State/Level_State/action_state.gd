class_name ActionState extends State

var level: Level
var vision_manager: VisionManager

var initial_num_alive_enemies: int 
var num_finished_moves: int
var alive_soldiers: Dictionary

var soldiers_in_action: Dictionary


func _init(data: Array):
	level = data[0]
	
	alive_soldiers = level.get_alive_soldiers()
	#soldiers_in_action = alive_soldiers.duplicate()
	soldiers_in_action = {}
	num_finished_moves = 0
	initial_num_alive_enemies = len(alive_soldiers)
	
	connect_to_signals()
	
	vision_manager = VisionManager.new()
	
	for player: Soldier in alive_soldiers.keys():	
		player.do_actions()

func connect_to_signals():
	Signals.player_move_finished.connect(_on_player_move_finished)
	Signals.player_move_continued.connect(_on_player_move_continued)
	Signals.enemy_soldier_killed.connect(_on_soldier_killed)
	
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
		#if not player.is_in_finished_state():
			#all_players_finished_moves = false
			
	#if all_players_finished_moves:
		#await level.get_tree().create_timer(1.0).timeout
		#level.set_level_state(PlayerSetMoveState.new([level]))

func check_for_deletion():
	for player in alive_soldiers.keys():
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			alive_soldiers.erase(player)

func _on_player_move_finished(soldier: Soldier):
	if soldiers_in_action.has(soldier):
		soldiers_in_action.erase(soldier)
		if len(soldiers_in_action) == 0:
			level.set_level_state(PlayerSetMoveState.new([level]))
			
	#num_finished_moves += 1
	#if num_finished_moves == initial_num_alive_enemies:
func _on_player_move_continued(soldier: Soldier):
	soldiers_in_action[soldier] = true
	
func _on_soldier_killed(enemy: Soldier, killed_by: Soldier):
	_on_player_move_finished(enemy)
	#initial_num_alive_enemies -= 1
	#num_finished_moves += 1
