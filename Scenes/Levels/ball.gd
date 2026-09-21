extends RigidBody2D

@export var impact_force: float = 400.0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player_hitbox"):
		var smer: Vector2 = (global_position - body.global_position).normalized()
		var rotacija_smer: float = sign(smer.x) if smer.x != 0 else 1.0
		var rotaciona_sila: float = 200.0 # Podesite po želji
		
		apply_central_impulse(smer * impact_force)
		apply_torque_impulse(rotacija_smer * rotaciona_sila)
