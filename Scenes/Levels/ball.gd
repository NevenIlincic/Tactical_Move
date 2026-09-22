extends RigidBody2D

@export var impact_force: float = 400.0
@export var rotation_force: float = 200.0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player_hitbox"):
		var direction: Vector2 = (global_position - body.global_position).normalized()
		var rotation_direction: float = sign(direction.x) if direction.x != 0 else 1.0
		
		apply_central_impulse(direction * impact_force)
		apply_torque_impulse(rotation_direction * rotation_force)
