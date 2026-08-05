extends Node2D 
class_name VisionManager

var alive_enemies: Dictionary

# Pamtićemo parove: { enemy: { player1: true, player2: true } }
var last_frame_visible_enemies: Dictionary
var current_frame_visible_enemies: Dictionary

func _init(enemies: Dictionary) -> void:
	alive_enemies = enemies
	last_frame_visible_enemies = {}
	current_frame_visible_enemies = {}
	connect_to_signals()

func connect_to_signals():
	Signals.get_alive_enemies.connect(_on_get_enemies)
	Signals.report_enemy_seen.connect(_on_enemy_seen_report)

func handle_enemy_visibility(delta: float):
	for enemy in current_frame_visible_enemies:
		if not last_frame_visible_enemies.has(enemy):
			var players: Array[Player] =[]
			for player in current_frame_visible_enemies[enemy].keys():
				players.append(player)
			Signals.show_enemy.emit(enemy, players)
		
		var enemy_data = current_frame_visible_enemies[enemy].duplicate()
		enemy_data["counter"] = 0
		last_frame_visible_enemies[enemy] = enemy_data
		
	var enemies_to_remove = []
	for enemy in last_frame_visible_enemies:
		if not current_frame_visible_enemies.has(enemy):
			last_frame_visible_enemies[enemy]["counter"] += 1
			
			if last_frame_visible_enemies[enemy]["counter"] > 5:
				var players: Array[Player] = []
				for key in last_frame_visible_enemies[enemy].keys():
					if not key is String:
						players.append(key)
				
				Signals.hide_enemy.emit(enemy, players)
				enemies_to_remove.append(enemy)
	
	for enemy in enemies_to_remove:
		last_frame_visible_enemies.erase(enemy)
		
	current_frame_visible_enemies.clear()
	
func _on_enemy_seen_report(enemy: Enemy, player: Node):
	if not current_frame_visible_enemies.has(enemy):
		current_frame_visible_enemies[enemy] = {}
	current_frame_visible_enemies[enemy][player] = true

func _on_get_enemies(enemies: Dictionary):
	alive_enemies = enemies

func get_enemies() -> Dictionary:
	return alive_enemies

func remove_from_alive_enemies(enemy: Enemy):
	alive_enemies.erase(enemy)
