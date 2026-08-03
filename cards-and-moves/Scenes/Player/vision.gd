extends Polygon2D 
class_name PlayerVision

@export var max_range: float = 300.0
@export var fov_degrees: float = 90.0
@export var ray_count: float = 30
@export var wall_collision_mask: int= 1

var rays: Array[RayCast2D] = []
var facing_angle: float = 0.0

func setup_vision_rays() -> void:
	var half_fov = deg_to_rad(fov_degrees / 2.0)
	for i in ray_count:
		var t = float(i) / (ray_count - 1)
		var angle = -half_fov + t * (2 * half_fov)
		var ray = RayCast2D.new()
		ray.target_position = Vector2(max_range, 0).rotated(angle)
		ray.collision_mask = wall_collision_mask
		ray.enabled = true
		add_child(ray)
		rays.append(ray)

func update_vision() -> void:
	var points: PackedVector2Array = [Vector2.ZERO]  # origin (player position)
	var half_fov = deg_to_rad(fov_degrees / 2.0)
	
	for i in rays.size():
		var t = float(i) / (rays.size() - 1)
		var angle = facing_angle - half_fov + t * (2 * half_fov)
		var ray = rays[i]
		
		ray.target_position = Vector2(max_range, 0).rotated(angle)
		ray.force_raycast_update()
		
		if ray.is_colliding():
			points.append(ray.to_local(ray.get_collision_point()))
		else:
			points.append(ray.target_position)
	
	self.polygon = points
