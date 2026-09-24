class_name VisionArea extends Area2D

@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var max_range: float = 900.0
@export var fov_degrees: float = 60.0
@export var ray_count: float = 75
@export var wall_collision_mask: int = 1
@onready var vision_polygon: SoldierVision = $"../Vision_Polygon"


var _dirs := PackedVector2Array()
var _last_pos := Vector2.INF
var _last_rot := INF
var _points := PackedVector2Array()

var space_state: PhysicsDirectSpaceState2D
var query: PhysicsRayQueryParameters2D

var enemies_in_view: Dictionary = {}
var parent_soldier: Soldier


func _ready() -> void:
	space_state = get_world_2d().direct_space_state

	parent_soldier = get_parent()
	var half := deg_to_rad(fov_degrees) * 0.5
	var pts := PackedVector2Array([Vector2.ZERO])
	var n := 8
	for i in n + 1:
		pts.append(Vector2.from_angle(-half + i * (half * 2.0) / n) * max_range)
	collision_polygon_2d.polygon = pts#	
	#if polygon_2d:
		#polygon_2d.polygon = pts
	query = PhysicsRayQueryParameters2D.new()
	query.collision_mask = 2 | parent_soldier.ENEMY_COLLISION_DETECTION_MASK
	
	wall_query = PhysicsRayQueryParameters2D.new()
	wall_query.collision_mask = 1
	wall_query.collide_with_areas = true
	wall_query.collide_with_bodies = true
	if parent_soldier and parent_soldier.hitbox:
		wall_query.exclude = [parent_soldier.hitbox.get_rid()]
	
	_build_dirs()
func _build_dirs() -> void:
	var fov := deg_to_rad(fov_degrees)
	var step := fov / ray_count
	_dirs.resize(ray_count + 1)
	for i in ray_count + 1:
		_dirs[i] = Vector2.from_angle(-fov * 0.5 + i * step)

func update_vision():
	space_state = get_world_2d().direct_space_state
	_check_enemies()
	if parent_soldier is Player:
		update_vision_polygon()

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
					if vision_polygon.bullet_hit_point == null:
						vision_polygon.bullet_hit_point = hit_position
					#if not enemy_position and hit_object == parent_soldier.enemy_to_shoot:
						#enemy_position = current_point
					Signals.report_enemy_seen.emit(hit_object, parent_soldier)
	#vision_polygon.update_polygon_points.emit(collision_polygon_2d.polygon, collision_polygon_2d.global_position, collision_polygon_2d.global_rotation)

# poligon računamo samo kad se vojnik pomerio ili rotirao
	if global_position.distance_squared_to(_last_pos) < 0.25 \
			and absf(angle_difference(global_rotation, _last_rot)) < 0.005:
		return
	_last_pos = global_position
	_last_rot = global_rotation

	#_rebuild_polygon()
	vision_polygon.update_polygon_points.emit(_points, global_position, global_rotation)



var wall_query: PhysicsRayQueryParameters2D

func check_is_enemy_soldier_hit(current_soldier: Soldier, hit_soldier: Soldier):
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
#################
var EDGE_DISTANCE: float = 24.0
@export var edge_precision: int = 5 # Broj koraka binarne pretrage za savršenu oštrinu ivice

func update_vision_polygon() -> void:
	space_state = get_world_2d().direct_space_state
	if not space_state:
		return

	var fov := deg_to_rad(fov_degrees)
	var step := fov / ray_count
	var start_angle := -fov / 2.0

	var points := PackedVector2Array()
	points.append(Vector2.ZERO)

	var origin := global_position
	var prev_dir := Vector2.ZERO
	var prev_dist := -1.0
	var prev_hit := false

	for i in range(ray_count + 1):
		var dir := Vector2.RIGHT.rotated(start_angle + i * step)
		var hit_info := _cast_ray_at_dir(dir, origin)

		# Ako imamo skok u udaljenosti, radimo binarnu pretragu da pronađemo tačan ugao/ćošak
		if prev_dist >= 0.0 and absf(hit_info.dist - prev_dist) > EDGE_DISTANCE:
			_find_exact_edge(prev_dir, dir, prev_dist, hit_info.dist, origin, points)

		points.append(dir * hit_info.dist)

		prev_dir = dir
		prev_dist = hit_info.dist

	vision_polygon.update_polygon_points.emit(points, global_position, global_rotation)


# Pomoćna funkcija za ispaljivanje zraka u određenom smeru
func _cast_ray_at_dir(dir: Vector2, origin: Vector2) -> Dictionary:
	var global_dir := dir.rotated(global_rotation)
	query.from = origin
	query.to = origin + global_dir * max_range

	var result := space_state.intersect_ray(query)
	if result:
		return {"dist": origin.distance_to(result["position"]), "hit": true}
	return {"dist": max_range, "hit": false}


# Binarna pretraga koja izoštrava ivicu prepreke
func _find_exact_edge(min_dir: Vector2, max_dir: Vector2, min_dist: float, max_dist: float, origin: Vector2, points: PackedVector2Array) -> void:
	var low_dir := min_dir
	var high_dir := max_dir
	var last_valid_info: Dictionary = {}

	for step in range(edge_precision):
		var mid_dir := (low_dir + high_dir).normalized()
		var mid_info := _cast_ray_at_dir(mid_dir, origin)

		# Ako se ponaša kao min_dir, pomeramo donju granicu
		if absf(mid_info.dist - min_dist) < absf(mid_info.dist - max_dist):
			low_dir = mid_dir
		else:
			high_dir = mid_dir
			
		last_valid_info = mid_info

	# Dodajemo tačno nađenu ivicu
	if last_valid_info.size() > 0:
		points.append(low_dir * _cast_ray_at_dir(low_dir, origin).dist)
		points.append(high_dir * _cast_ray_at_dir(high_dir, origin).dist)
