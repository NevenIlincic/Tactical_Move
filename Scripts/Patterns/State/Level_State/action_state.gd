class_name ActionState extends State

var level: Level
#var vision_manager: VisionManager

var initial_num_alive_enemies: int 
var num_finished_moves: int
var num_player_finished_moves: int
var alive_soldiers: Dictionary
var alive_players: Dictionary
var current_action_killed_players: Dictionary

var soldiers_in_action: Dictionary

var action_duration: float = 0.0

func _init(data: Array):
	level = data[0]
	level.players_set_for_move = {}
	level.players_set_for_rotation = {}
	alive_soldiers = level.get_alive_soldiers()
	alive_players = level.get_alive_players()
	current_action_killed_players = {}
	soldiers_in_action = alive_soldiers.duplicate(true)
	#soldiers_in_action = {}
	num_finished_moves = 0
	initial_num_alive_enemies = len(alive_soldiers)
	
	num_player_finished_moves = 0
	connect_to_signals()
	
	#vision_manager = VisionManager.new()
	for player: Soldier in alive_soldiers.keys():	
		player.do_actions()
	
	level.current_state_label.text = "ACTION STATE"
	
	
	
func connect_to_signals():
	Signals.player_move_finished.connect(_on_player_move_finished)
	Signals.player_move_continued.connect(_on_player_move_continued)
	Signals.enemy_soldier_killed.connect(_on_soldier_killed)
	Signals.stop_enemy_actions.connect(_on_stop_enemy_actions)
func _unhandled_input(event: InputEvent):
	pass

func _physics_process(delta: float) -> void:
	level.total_passed_time_millis += int(delta * 1000.0)
	action_duration += delta
	var all_players_finished_moves: bool = true
	
	check_for_deletion()
			
	for player: Soldier in alive_soldiers.keys():
		player.do_while_action(delta)
		
func check_for_deletion():
	for player in alive_soldiers.keys():
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			alive_soldiers.erase(player)

func _on_player_move_finished(soldier: Soldier):
	if soldiers_in_action.has(soldier):
		soldiers_in_action.erase(soldier)
		
	if soldier is Player:
		num_player_finished_moves += 1
	
	var enemies_finished: Array[Soldier] = []
	if num_player_finished_moves == alive_players.size():
		for enemy_soldier in soldiers_in_action:
			if is_instance_valid(enemy_soldier) and not enemy_soldier.is_queued_for_deletion() and enemy_soldier is Enemy:
				if enemy_soldier.enemies_in_sight.is_empty():
					enemy_soldier._on_players_action_finished()
					enemies_finished.append(enemy_soldier)
		#level.set_level_state(PlayerSetMoveState.new([level]))
		
	for enemy in enemies_finished:
		soldiers_in_action.erase(enemy)
	
	if soldiers_in_action.is_empty():
		num_player_finished_moves = 0
		for player_id: String in alive_players:
			#print(player.soldier_id, " ", current_action_killed_players)
			if not current_action_killed_players.has(player_id):
				var player: Player = alive_players[player_id]
				player.is_queued_for_medic_healing = false
				player.healing_needed_sprite.visible = false
				if player is MedicPlayer:
					player._check_is_healing_available(action_duration)
		level.set_level_state(PreparationState.new([level]))
		
func _on_player_move_continued(soldier: Soldier):
	soldiers_in_action[soldier] = true
	
func _on_soldier_killed(enemy: Soldier, killed_by: Soldier):
	current_action_killed_players[enemy.soldier_id] = enemy
	_on_player_move_finished(enemy)

func _on_stop_enemy_actions(enemy_soldier: Soldier):
	if soldiers_in_action.has(enemy_soldier):
		soldiers_in_action.erase(enemy_soldier)
	

func disconnect_signals():
	if Signals.player_move_finished.is_connected(_on_player_move_finished):
		Signals.player_move_finished.disconnect(_on_player_move_finished)
	if Signals.player_move_continued.is_connected(_on_player_move_continued):
		Signals.player_move_continued.disconnect(_on_player_move_continued)
	if Signals.enemy_soldier_killed.is_connected(_on_soldier_killed):
		Signals.enemy_soldier_killed.disconnect(_on_soldier_killed)
