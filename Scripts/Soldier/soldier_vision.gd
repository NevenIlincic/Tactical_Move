class_name SoldierVision extends Polygon2D

@onready var vision_center_line: Line2D = $Vision_Center_Line
@onready var collision_polygon_2d: CollisionPolygon2D = $Vision_Area/CollisionPolygon2D


@export var max_range: float = 300.0
@export var fov_degrees: float = 90.0
@export var ray_count: float = 75
@export var wall_collision_mask: int= 1

var level: Level

var rays: Array[RayCast2D] = []
var facing_angle: float = 0.0

func _ready() -> void:
	setup_vision_rays()
	level = get_tree().get_first_node_in_group("Level")

func setup_vision_rays() -> void:
	var half_fov = deg_to_rad(fov_degrees / 2.0)
	for i in ray_count:
		var t = float(i) / (ray_count - 1)
		var angle = -half_fov + t * (2 * half_fov)
		var ray = RayCast2D.new()
		ray.target_position = Vector2(max_range, 0).rotated(angle)
		ray.collision_mask = wall_collision_mask
		ray.enabled = true
		ray.collide_with_areas = true
		ray.set_collision_mask_value(3, false)
		add_child(ray)
		rays.append(ray)

func update_vision():
	var half_fov = deg_to_rad(fov_degrees / 2.0)
	var raw_points: Array[Vector2] = [Vector2.ZERO]
	var points = PackedVector2Array(raw_points)
	var currently_visible_enemies: Dictionary = {}
	
	for i in rays.size():
		var t = float(i) / (rays.size() - 1)
		var angle = facing_angle - half_fov + t * (2 * half_fov)
		var ray = rays[i]
		
		ray.target_position = Vector2(max_range, 0).rotated(angle)
		ray.force_raycast_update()
		
		var current_point: Vector2
		
		if ray.is_colliding():
			current_point = ray.to_local(ray.get_collision_point())
			var hit_object = ray.get_collider().get_parent()
			if hit_object and hit_object is Soldier:
				if check_is_enemy_soldier_hit(get_parent(), hit_object):
					if not currently_visible_enemies.has(hit_object):
						currently_visible_enemies[hit_object] = true					
						Signals.report_enemy_seen.emit(hit_object, get_parent())
		else:
			current_point = ray.target_position
		
		points.append(current_point)
		if raw_points.back().distance_to(current_point) > 0.5:
			raw_points.append(current_point)
		if i == rays.size() / 2:
			if vision_center_line.get_point_count() > 1:
				vision_center_line.set_point_position(1, current_point)
			else:
				vision_center_line.add_point(current_point)

	if points.size() > 3:
		var triangles = Geometry2D.triangulate_polygon(points)
		if not triangles.is_empty():
			self.polygon = points
			#collision_polygon_2d.polygon = points
		else:
			pass

func check_is_enemy_soldier_hit(current_soldier: Soldier, hit_soldier: Soldier):
	return current_soldier.get_script() != hit_soldier.get_script()
	#if hit_soldier and hit_soldier is Enemy:
		#if not currently_visible_enemies.has(hit_soldier):
			#currently_visible_enemies[hit_soldier] = true
