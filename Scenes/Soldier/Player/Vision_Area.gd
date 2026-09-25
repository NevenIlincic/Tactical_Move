#class_name VisionArea extends Area2D
#
#@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
#
#@export var max_range: float = 900.0
#@export var fov_degrees: float = 60.0
#@export var ray_count: float = 75
#@export var wall_collision_mask: int = 1
#@onready var vision_polygon: SoldierVision = $"../Vision_Polygon"
#@onready var player_vision_cone: Line2D = $Player_Vision_Cone
#
#
#var _dirs := PackedVector2Array()
#var _last_pos := Vector2.INF
#var _last_rot := INF
#var _points := PackedVector2Array()
#
#var space_state: PhysicsDirectSpaceState2D
#var query: PhysicsRayQueryParameters2D
#
#var enemies_in_view: Dictionary = {}
#var parent_soldier: Soldier
#
#
#func _ready() -> void:
	#space_state = get_world_2d().direct_space_state
#
	#parent_soldier = get_parent()
	#var half := deg_to_rad(fov_degrees) * 0.5
	#var pts := PackedVector2Array([Vector2.ZERO])
	#var n := 8
	#for i in n + 1:
		#pts.append(Vector2.from_angle(-half + i * (half * 2.0) / n) * max_range)
	#collision_polygon_2d.polygon = pts#	
	#player_vision_cone.points = pts
	##player_vision_cone.add_point(Vector2.ZERO)
	##if polygon_2d:
		##polygon_2d.polygon = pts
	#query = PhysicsRayQueryParameters2D.new()
	#query.collision_mask = 2 | parent_soldier.ENEMY_COLLISION_DETECTION_MASK
	#
#func update_vision():
	#space_state = get_world_2d().direct_space_state
	#_check_enemies()
#
#func _check_enemies():
	#for enemy_soldier_id in enemies_in_view:
		#if not is_instance_valid(enemies_in_view[enemy_soldier_id]) or enemies_in_view[enemy_soldier_id].is_queued_for_deletion():
			#continue
		#var enemy: Soldier = enemies_in_view[enemy_soldier_id]
		#if enemy.is_killed:
			#continue
			#
		#query.from = global_position
		#query.to = enemy.global_position
		#var result: Dictionary = space_state.intersect_ray(query)
		#if result:
			#var hit_object: Object = result["collider"].get_parent()
			#var hit_position: Vector2 = result["position"]
			#if hit_object and hit_object is Soldier:
				#if hit_object.is_killed:
					#continue
				#if check_is_enemy_soldier_hit(parent_soldier, hit_object):
					#if vision_polygon.bullet_hit_point == null:
						#vision_polygon.bullet_hit_point = hit_position
					##if not enemy_position and hit_object == parent_soldier.enemy_to_shoot:
						##enemy_position = current_point
					#Signals.report_enemy_seen.emit(hit_object, parent_soldier)
	##vision_polygon.update_polygon_points.emit(collision_polygon_2d.polygon, collision_polygon_2d.global_position, collision_polygon_2d.global_rotation)
#
#
#var wall_query: PhysicsRayQueryParameters2D
#
#func check_is_enemy_soldier_hit(current_soldier: Soldier, hit_soldier: Soldier):
	#return current_soldier.soldier_type != hit_soldier.soldier_type
#
#
#func _on_body_entered(body: Node2D) -> void:
	#var soldier = body.get_parent()
	#if soldier is Soldier and soldier.soldier_id != parent_soldier.soldier_id:
		#var enemy_soldier: Soldier = soldier
		#if enemy_soldier.is_killed:
			#return
		#if check_is_enemy_soldier_hit(parent_soldier, enemy_soldier):
			#enemies_in_view[enemy_soldier.soldier_id] = enemy_soldier
#
#func _on_body_exited(body: Node2D) -> void:
	#var soldier = body.get_parent()
	#if soldier is Soldier and soldier.soldier_id != parent_soldier.soldier_id:
		#var enemy_soldier: Soldier = soldier
		#if enemies_in_view.has(enemy_soldier.soldier_id):
			#enemies_in_view.erase(enemy_soldier.soldier_id)
##################
##func _update_vision_polygon():
	##vision_polygon.update_polygon_points.emit(collision_polygon_2d.polygon, collision_polygon_2d.global_position, collision_polygon_2d.global_rotation)
#
#######
class_name VisionArea extends Area2D

@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var vision_polygon: SoldierVision = $"../Vision_Polygon"

@export var max_range: float = 900.0
@export var fov_degrees: float = 60.0
@export var ray_count: int = 50 # Smanjeno sa 75 na 50 jer dodajemo Edge Detection koji je mnogo precizniji!
@export var wall_collision_mask: int = 1
@export var edge_precision_iterations: int = 5 # Broj podela za traženje tačnog ugla zida

var _dirs := PackedVector2Array()
var space_state: PhysicsDirectSpaceState2D
var query: PhysicsRayQueryParameters2D
var wall_query: PhysicsRayQueryParameters2D

var enemies_in_view: Dictionary = {}
var parent_soldier: Soldier

var can_draw_vision: bool = false

func enable_drawing_vision_sight():
	can_draw_vision = true
	_update_vision_polygon_ultra_precise()
func disable_drawing_vision_sight():
	can_draw_vision = false
	#player_vision_cone.points = player_vision_cone.points.slice(0, 1)
	vision_polygon.update_polygon_points.emit([], global_position, global_rotation)


func _ready() -> void:
	space_state = get_world_2d().direct_space_state
	parent_soldier = get_parent()
	
	var half := deg_to_rad(fov_degrees) * 0.5
	var pts := PackedVector2Array([Vector2.ZERO])
	var n := 8
	for i in n + 1:
		pts.append(Vector2.from_angle(-half + i * (half * 2.0) / n) * max_range)
	collision_polygon_2d.polygon = pts#	
	
	query = PhysicsRayQueryParameters2D.new()
	query.collision_mask = 2 | parent_soldier.ENEMY_COLLISION_DETECTION_MASK
	
	wall_query = PhysicsRayQueryParameters2D.new()
	wall_query.collision_mask =  2 | parent_soldier.ENEMY_COLLISION_DETECTION_MASK
	wall_query.collide_with_areas = false
	wall_query.collide_with_bodies = true
	
	if parent_soldier and parent_soldier.hitbox:
		wall_query.exclude = [parent_soldier.hitbox.get_rid()]
	
	_build_dirs()




func _build_dirs() -> void:
	var fov := deg_to_rad(fov_degrees)
	var step := fov / ray_count
	_dirs.resize(ray_count + 1)
	for i in range(ray_count + 1):
		_dirs[i] = Vector2.from_angle(-fov * 0.5 + i * step)


var frame_counter: int = 2

func update_vision() -> void:
	frame_counter = (frame_counter + 1) % 3
	space_state = get_world_2d().direct_space_state
	_check_enemies()
	if frame_counter == 0 and can_draw_vision:
		_update_vision_polygon_ultra_precise()



func _update_vision_polygon_ultra_precise() -> void:
	var pts := PackedVector2Array()
	pts.append(Vector2.ZERO) # Centar uvek u (0,0) lokalno
	
	var prev_hit := false
	var prev_point := Vector2.ZERO
	var prev_angle := 0.0
	
	for i in range(_dirs.size()):
		var dir := _dirs[i]
		var global_target := global_position + dir.rotated(global_rotation) * max_range
		
		wall_query.from = global_position
		wall_query.to = global_target
		
		var result := space_state.intersect_ray(wall_query)
		
		var current_hit := false
		var current_point := Vector2.ZERO
		
		if result:
			current_hit = true
			current_point = to_local(result["position"])
		else:
			current_point = dir * max_range
		
		if i > 0:
			var angle_from := _dirs[i - 1].angle()
			var angle_to := dir.angle()
			var distance_diff := prev_point.distance_to(current_point)
			
			if prev_hit != current_hit or distance_diff > 30.0:
				var edge_pt := _find_exact_edge(angle_from, angle_to)
				pts.append(edge_pt)
		
		pts.append(current_point)
		
		prev_hit = current_hit
		prev_point = current_point

	#if is_instance_valid(player_vision_cone):
		#player_vision_cone.points = pts
		#
	if is_instance_valid(vision_polygon):
		vision_polygon.update_polygon_points.emit(pts, global_position, global_rotation)


func _find_exact_edge(min_angle: float, max_angle: float) -> Vector2:
	var min_a := min_angle
	var max_a := max_angle
	var last_valid_pt := Vector2.ZERO
	
	for iter in range(edge_precision_iterations):
		var mid_angle := (min_a + max_a) * 0.5
		var mid_dir := Vector2.from_angle(mid_angle)
		var global_target := global_position + mid_dir.rotated(global_rotation) * max_range
		
		wall_query.from = global_position
		wall_query.to = global_target
		
		var result := space_state.intersect_ray(wall_query)
		if result:
			last_valid_pt = to_local(result["position"])
			max_a = mid_angle
		else:
			last_valid_pt = mid_dir * max_range
			min_a = mid_angle
			
	return last_valid_pt


func _check_enemies():
	for enemy_soldier_id in enemies_in_view:
		if not is_instance_valid(enemies_in_view[enemy_soldier_id]) or enemies_in_view[enemy_soldier_id].is_queued_for_deletion():
			continue
		var enemy: Soldier = enemies_in_view[enemy_soldier_id]
		if enemy.is_killed:
			continue
			
		query.from = global_position
		query.to = enemy.global_position
		var result: Dictionary = space_state.intersect_ray(query)
		if result:
			var hit_object: Object = result["collider"].get_parent()
			var hit_position: Vector2 = result["position"]
			if hit_object and hit_object is Soldier:
				if hit_object.is_killed:
					continue
				if check_is_enemy_soldier_hit(parent_soldier, hit_object):
					#if vision_polygon.bullet_hit_point == null:
					vision_polygon.bullet_hit_point = hit_position
					Signals.report_enemy_seen.emit(hit_object, parent_soldier)


func check_is_enemy_soldier_hit(current_soldier: Soldier, hit_soldier: Soldier) -> bool:
	return current_soldier.soldier_type != hit_soldier.soldier_type


func _on_body_entered(body: Node2D) -> void:
	var soldier = body.get_parent()
	if soldier is Soldier and soldier.soldier_id != parent_soldier.soldier_id:
		var enemy_soldier: Soldier = soldier
		if enemy_soldier.is_killed:
			return
		if check_is_enemy_soldier_hit(parent_soldier, enemy_soldier):
			enemies_in_view[enemy_soldier.soldier_id] = enemy_soldier


func _on_body_exited(body: Node2D) -> void:
	var soldier = body.get_parent()
	if soldier is Soldier and soldier.soldier_id != parent_soldier.soldier_id:
		var enemy_soldier: Soldier = soldier
		if enemies_in_view.has(enemy_soldier.soldier_id):
			enemies_in_view.erase(enemy_soldier.soldier_id)
