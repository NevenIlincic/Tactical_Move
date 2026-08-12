extends Node2D 
class_name EnemyVisionManager

var alive_enemies: Dictionary

#{ player: { enemy1: true, enemy2: true } }
var last_frame_visible_player: Dictionary
var current_frame_visible_player: Dictionary

func _init(enemies: Dictionary) -> void:
	alive_enemies = enemies
	last_frame_visible_player = {}
	current_frame_visible_player = {}
	connect_to_signals()

func connect_to_signals():
	Signals.report_player_seen.connect(_on_player_seen_report)

func handle_enemy_visibility(delta: float):
	#Checks is enemy entered in sight
	_check_is_enemy_entered_vision()
	_check_is_enemy_exited_vision()
	#print(last_frame_visible_enemies, " ", current_frame_visible_enemies)

	
	current_frame_visible_player.clear()

func _check_is_enemy_entered_vision():
	for player in current_frame_visible_player:
		if last_frame_visible_player.has(player):
			var player_seen_by: Dictionary = current_frame_visible_player[player].duplicate()
			for enemy in player_seen_by:
				if not last_frame_visible_player[player].has(enemy):
					last_frame_visible_player[player][enemy] = 0
					Signals.shoot_player.emit(enemy, player)
		else:
			var player_seen_by: Dictionary = current_frame_visible_player[player].duplicate()
			#last_frame_visible_enemies[enemy] = enemy_seen_by
			for enemy in player_seen_by:
				if not last_frame_visible_player.has(enemy):
					last_frame_visible_player[player] = {}
				last_frame_visible_player[player][enemy] = 0
				Signals.shoot_player.emit(enemy, player)
			#var enemy_data = current_frame_visible_enemies[enemy].duplicate()
			#enemy_data["counter"] = 0

func _check_is_enemy_exited_vision():
	var players_to_remove = []
	var break_outer_loop: bool = false
	for player in last_frame_visible_player:
		var enemies_to_remove_from_player = []
		if not current_frame_visible_player.has(player):
			for enemy in last_frame_visible_player[player]:
				if last_frame_visible_player[player][enemy] >= 10:
					if player: #Provera da nije ubijen!
						Signals.hide_player.emit(enemy, player)
					enemies_to_remove_from_player.append(enemy)
			
					#last_frame_visible_enemies[enemy][player]["counter"] = 0
				else:
					last_frame_visible_player[player][enemy] += 1
		else:
			for enemy in last_frame_visible_player[player]:
				if not current_frame_visible_player[player].has(enemy):
					if last_frame_visible_player[player][enemy] >= 10:
						Signals.hide_player.emit(enemy, player)
						enemies_to_remove_from_player.append(enemy)
					else:
						last_frame_visible_player[player][enemy] += 1
	
		for enemy in enemies_to_remove_from_player:
			last_frame_visible_player[player].erase(enemy)
			
		if last_frame_visible_player[player].is_empty():
			players_to_remove.append(player)
			
	for player in players_to_remove:
		last_frame_visible_player.erase(player)
func _on_player_seen_report(enemy: Enemy, player: Player):
	if not current_frame_visible_player.has(enemy):
		current_frame_visible_player[enemy] = {}
	current_frame_visible_player[enemy][player] = true

func _on_get_enemies(enemies: Dictionary):
	alive_enemies = enemies

func get_enemies() -> Dictionary:
	return alive_enemies

func remove_from_alive_enemies(enemy: Enemy):
	alive_enemies.erase(enemy)
