class_name Enemy extends Soldier

#SCENE NODES
@onready var enemy_sprite: Sprite2D = $Enemy_Sprite
@export var HP: float = 100.0
#FOR PLAYER
var num_seen_by: int = 0

#FOR ENEMY
var alive_players: Dictionary = {}
var level: Level
var recent_covers: Array[Marker2D] = []
const MAX_RECENT_COVERS: int = 2

enum Intent{
	ATTACK,
	DEFEND
}

func when_spotted():
	visible = true
	num_seen_by += 1 

func when_escaped():
	num_seen_by -= 1
	if num_seen_by == 0:
		visible = false

func _ready() -> void:
	super._ready()
	#visible = false
	engagement_strategy = StopShootFollowingStrategy.new()
	point_to_look = Vector2.ZERO
	level = get_tree().get_first_node_in_group("Level")
	Signals.stop_enemy_actions.connect(_on_players_action_finished)

func _on_players_action_finished():
	reset_path()
	if move_tween and is_instance_valid(move_tween):
		move_tween.kill()
	is_walking = false

func set_point_to_look(point):
	point_to_look = point
	if not check_is_point_to_look_vector():
		point_to_look = point.global_position


func _pre_move_actions():
	var best_move = evaluate_best_move()
	var total_score: float = best_move["total_score"]
	var intent: Intent = best_move["intent"]
	#TARGET
	var target: Soldier = best_move["target"]
	var target_distance: float = best_move["target_distance"]
	var path_to_target = best_move["path_to_target"]
	#COVER
	var path_to_closest_cover = best_move["path_to_closest_cover"]
	var _distance_to_closest_cover: float = best_move["distance_to_closest_cover"]
	var cover_point: Marker2D = best_move["closest_cover"]
	
	#print(self, " ", best_move)
	match intent:
		Intent.DEFEND:
			if soldier_stats.HP.get_value() < target.soldier_stats.HP.get_value():
				if total_score > 1.0:
					var path: Array[Vector2] = []
					for point in path_to_closest_cover:
						path.append(point)
					player_path = path	
					set_after_move_looking_point(cover_point.global_position)
		
		Intent.ATTACK:
			var path: Array[Vector2] = []
			var look_at_point = null
			if soldier_stats.max_travel_distance.get_value() < target_distance:
				for point in path_to_closest_cover:
					path.append(point)
				look_at_point = cover_point
			else:
				for point in path_to_target:
					path.append(point)
				look_at_point = target
			set_point_to_look(look_at_point)
			player_path = path
	
	check_soldier_has_action()
	
func check_enemy_looking_at():
	if enemy_to_shoot:
		look_at(enemy_to_shoot.global_position)
	else:
		look_at(point_to_look)

func _on_enemy_lost_extra(_enemy: Soldier) -> void:
	pass
	#print("OVDE")
	#hide_enemy()

func evaluate_best_move():
	var map_rid = get_world_2d().navigation_map

	var path_data: Dictionary = get_closest_cover()
	#print(last_cover)
	var path_to_closest_cover = path_data["shortest_path"]
	var distance_to_closest_cover = path_data["minimum_length"] 
	var cover_point: Marker2D = path_data["closest_cover"]
	
	alive_players = level.get_alive_players()
	
	var best_move: Dictionary = {}
	var best_score: float = -9999.0
	
	var current_HP: float = soldier_stats.HP.get_value()
	var max_travel_distance: float = soldier_stats.max_travel_distance.get_value()
	for player: Player in alive_players:
		var intent_for_player: Intent = Intent.ATTACK
		var path_to_player = NavigationServer2D.map_get_path(map_rid, global_position, player.global_position, true)
		var distance_to_player: float = get_path_length(path_to_player)
		var player_allies_nearby = len(player.allies_nearby)
		
		var attack_score: float = 0.0
		var defense_score: float = 0.0
		
		var player_hp: float = player.soldier_stats.HP.get_value()	
		#HP
		if current_HP > player_hp:
			attack_score += clampf(10.0/(player.soldier_stats.HP.get_value() +1.0), 0.0, 3.0)
			if player_hp < 30.0:
				attack_score += attack_score * 0.5
			else:
				attack_score += attack_score * 0.2
		else:
			defense_score += clampf(10.0/(player.soldier_stats.HP.get_value() +1.0), 0.0, 3.0)
			if current_HP < 30.0:
				defense_score = 10.0 / current_HP
		#DISTANCE
		if max_travel_distance > distance_to_player:
			attack_score += clampf(500.0/(distance_to_player*(player_allies_nearby+1)), 0.0, 3.0)
			if distance_to_player > distance_to_closest_cover:
				defense_score += clampf(500.0/ (distance_to_player*(player_allies_nearby+1)), 0.0, 3.0)
			else:
				attack_score += clampf(500.0/(distance_to_player*(player_allies_nearby+1)), 0.0, 3.0)
		else:
			defense_score += clampf(500.0/ (distance_to_player*(player_allies_nearby+1)), 0.0, 3.0)
		
		#print(self, " ", attack_score, " ", defense_score)
		if defense_score > attack_score:
			intent_for_player = Intent.DEFEND
		
		var total_score: float = absf(attack_score - defense_score)
		if total_score > best_score:
			best_score = total_score
			best_move = {
				"total_score": total_score,
				"intent": intent_for_player,
				"target": player,
				"target_distance": distance_to_player,
				"path_to_target": path_to_player,
				"path_to_closest_cover": path_to_closest_cover,
				"closest_cover": cover_point,
				"distance_to_closest_cover": distance_to_closest_cover
			}
	
	return best_move
func get_nearest_marker(from_position: Vector2, markers: Array) -> Marker2D:
	var nearest_marker: Marker2D = null
	var shortest_distance: float = INF # Postavljamo na beskonačno na početku
	
	for marker in markers:
		if not is_instance_valid(marker):
			continue
			
		var current_distance = from_position.distance_to(marker.global_position)
		
		if current_distance < shortest_distance:
			shortest_distance = current_distance
			nearest_marker = marker
			
	return nearest_marker

func get_path_lenth_to_cover(cover: Marker2D):
	var map_rid = get_world_2d().navigation_map

	var path = NavigationServer2D.map_get_path(map_rid, global_position, cover.global_position, true)
	var total_length = 0.0
	
	total_length = get_path_length(path)
	return {
		"cover": cover,
		"path_length": total_length,
		"path": path
	}

func get_closest_cover():
	var best_cover: Marker2D = null
	var best_path = null
	var best_length: float = INF
	for cover: Marker2D in level.cover_points:
		if player_path[-1] == cover.global_position or cover in recent_covers:
			continue
		var data: Dictionary = get_path_lenth_to_cover(cover)
		if best_length > data["path_length"]:
			best_length = data["path_length"]
			best_cover = data["cover"]
			best_path = data["path"]
		
	if best_cover:
		recent_covers.append(best_cover)
		if recent_covers.size() > MAX_RECENT_COVERS:
			recent_covers.pop_front()
	
	return {
		"shortest_path": best_path,
		"minimum_length": best_length,
		"closest_cover": best_cover
		}

func get_path_length(path):
	var total_length: float = 0.0
	for i in range(path.size() - 1):
		total_length += path[i].distance_to(path[i + 1])
	return total_length
