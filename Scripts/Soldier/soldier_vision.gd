class_name SoldierVision extends Polygon2D

@onready var enemy_target_line: Line2D = $Enemy_Target_Line
@onready var point_light_2d: PointLight2D = $PointLight2D

@export var max_range: float = 300.0
@export var fov_degrees: float = 90.0
@export var ray_count: float = 75
@export var wall_collision_mask: int= 1

var are_rays_enabled: bool = false

var level: Level

var rays: Array[RayCast2D] = []
var facing_angle: float = 0.0

var bullet_hit_point #Vector2/null

func _ready() -> void:
	enemy_target_line.add_point(Vector2.ZERO)
	
	setup_vision_rays()
	level = get_tree().get_first_node_in_group("Level")
	
	if point_light_2d:
		point_light_2d.rotate(deg_to_rad(90))
	
	
func setup_vision_rays() -> void:
	var half_fov = deg_to_rad(fov_degrees / 2.0)
	for i in ray_count:
		var t = float(i) / (ray_count - 1)
		var angle = -half_fov + t * (2 * half_fov)
		var ray = RayCast2D.new()
		ray.target_position = Vector2(max_range, 0).rotated(angle)
		#ray.collision_mask = wall_collision_mask
		ray.set_collision_mask_value(1, true)
		ray.set_collision_mask_value(2, true)
		ray.enabled = true
		#ray.collide_with_areas = true
		ray.set_collision_mask_value(3, false)
		add_child(ray)
		rays.append(ray)
		
func disable_rays():
	for ray: RayCast2D in rays:
		ray.enabled = false
		are_rays_enabled = false

func enable_rays():
	for ray: RayCast2D in rays:
		ray.enabled = true
		are_rays_enabled = true

func update_vision():
	var enemy_position: Vector2
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
				if hit_object.is_killed:
					return
				if check_is_enemy_soldier_hit(get_parent(), hit_object):
					if not currently_visible_enemies.has(hit_object):
						currently_visible_enemies[hit_object] = true
						bullet_hit_point = hit_object.global_position
						if not enemy_position and hit_object == get_parent().enemy_to_shoot:
							enemy_position = current_point
						Signals.report_enemy_seen.emit(hit_object, get_parent())
						
		else:
			current_point = ray.target_position
		
		points.append(current_point)
		if raw_points.back().distance_to(current_point) > 0.5:
			raw_points.append(current_point)
			
	if points.size() > 3:
		var triangles = Geometry2D.triangulate_polygon(points)
		if not triangles.is_empty():
			self.polygon = points

		else:
			pass
			
			
		
	
func check_is_enemy_soldier_hit(current_soldier: Soldier, hit_soldier: Soldier):
	return current_soldier.soldier_type != hit_soldier.soldier_type

func reset_target_line():
	enemy_target_line.remove_point(-1)

func draw_bullet_line():
	pass
