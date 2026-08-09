extends Node2D 
class_name VisionManager


# Pamtićemo parove: { enemy: { player1: true, player2: true } }
var last_frame_visible_enemies: Dictionary
var current_frame_visible_enemies: Dictionary

func _init() -> void:
	last_frame_visible_enemies = {}
	current_frame_visible_enemies = {}
	connect_to_signals()

func connect_to_signals():
	Signals.report_enemy_seen.connect(_on_enemy_seen_report)

func handle_enemy_visibility(delta: float):
	_check_is_enemy_entered_vision()
	_check_is_enemy_exited_vision()
	current_frame_visible_enemies.clear()

func _check_is_enemy_entered_vision():
	for enemy in current_frame_visible_enemies:
		if last_frame_visible_enemies.has(enemy):
			var enemy_seen_by: Dictionary = current_frame_visible_enemies[enemy].duplicate()
			for player in enemy_seen_by:
				if not last_frame_visible_enemies[enemy].has(player):
					last_frame_visible_enemies[enemy][player] = 0
					Signals.show_enemy.emit(enemy, player)
		else:
			var enemy_seen_by: Dictionary = current_frame_visible_enemies[enemy].duplicate()
			#last_frame_visible_enemies[enemy] = enemy_seen_by
			for player in enemy_seen_by:
				if not last_frame_visible_enemies.has(enemy):
					last_frame_visible_enemies[enemy] = {}
				last_frame_visible_enemies[enemy][player] = 0
				Signals.show_enemy.emit(enemy, player)
			#var enemy_data = current_frame_visible_enemies[enemy].duplicate()
			#enemy_data["counter"] = 0

func _check_is_enemy_exited_vision():
	var enemies_to_remove = []
	var break_outer_loop: bool = false
	for enemy in last_frame_visible_enemies:
		var players_to_remove_from_enemy = []
		if not current_frame_visible_enemies.has(enemy):
			for player in last_frame_visible_enemies[enemy]:
				if last_frame_visible_enemies[enemy][player] >= 5:
					if enemy and player: #Provera da nije ubijen!
						Signals.hide_enemy.emit(enemy, player)
					players_to_remove_from_enemy.append(player)
			
					#last_frame_visible_enemies[enemy][player]["counter"] = 0
				else:
					last_frame_visible_enemies[enemy][player] += 1
		else:
			for player in last_frame_visible_enemies[enemy]:
				if not current_frame_visible_enemies[enemy].has(player):
					if last_frame_visible_enemies[enemy][player] >= 5:
						if enemy and player:
							Signals.hide_enemy.emit(enemy, player)
							players_to_remove_from_enemy.append(player)
					else:
						last_frame_visible_enemies[enemy][player] += 1
	
		for player in players_to_remove_from_enemy:
			last_frame_visible_enemies[enemy].erase(player)
			
		if last_frame_visible_enemies[enemy].is_empty():
			enemies_to_remove.append(enemy)
			
	for enemy in enemies_to_remove:
		last_frame_visible_enemies.erase(enemy)
		
func _on_enemy_seen_report(enemy: Soldier, player: Soldier):
	if not current_frame_visible_enemies.has(enemy):
		current_frame_visible_enemies[enemy] = {}
	current_frame_visible_enemies[enemy][player] = true
