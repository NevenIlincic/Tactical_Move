class_name Enemy extends Soldier

#SCENE NODES
@onready var enemy_sprite: Sprite2D = $Enemy_Sprite
@export var HP: float = 100.0
#FOR PLAYER
var num_seen_by: int = 0

#FOR ENEMY
var alive_players: Dictionary = {}
var level: Level

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

func set_point_to_look(point):
	point_to_look = point
	if not check_is_point_to_look_vector():
		point_to_look = point.global_position


func _pre_move_actions():
	evaluate_best_move()
	Signals.player_move_finished.emit(self)
	#check_soldier_has_action()
	
func check_enemy_looking_at():
	if enemy_to_shoot:
		look_at(enemy_to_shoot.global_position)
	else:
		look_at(point_to_look)

func _on_enemy_lost_extra(enemy: Soldier) -> void:
	pass
	#print("OVDE")
	#hide_enemy()

func evaluate_best_move():
	var path_data: Dictionary = get_closest_cover()
	var path = path_data["shortest_path"]
	var distance_to_nearest_cover = path_data["minimum_length"] 
	var cover_point: Marker2D = path_data["closest_cover"]
	
	var alive_players: Dictionary = level.get_alive_players()
	var best_move: Dictionary = {}
	var best_score: float = 0.0
	
	var current_HP: float = soldier_stats.HP.get_value()
	for player in alive_players:
		pass

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
	
	for i in range(path.size() - 1):
		total_length += path[i].distance_to(path[i + 1])
	return {
		"cover": cover,
		"path_length": total_length,
		"path": path
	}

func get_closest_cover():
	var best_cover: Marker2D = null
	var best_path = null
	var best_length: float = INF
	for cover in level.cover_points:
		var data: Dictionary = get_path_lenth_to_cover(cover)
		if best_length > data["path_length"]:
			best_length = data["path_length"]
			best_cover = data["cover"]
			best_path = data["path"]
	return {
		"shortest_path": best_path,
		"minimum_length": best_length,
		"closest_cover": best_cover
		}
