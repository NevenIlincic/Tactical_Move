class_name MuzzleCocoon extends RigidBody2D

const IMPULSE_MIN_VALUE: float = 100.0
const IMPULSE_MAX_VALUE: float = 150.0
const TORQUE_IMPULSE_MIN_VALUE: float = -50.0
const TORQUE_IMPULSE_MAX_VALUE: float = 50.0
const LINEAR_DAMP: float = 4.0

@onready var muzzle_sprite: Sprite2D = $Muzzle_Sprite

func do_dropout_effect(starting_position: Vector2, player_rotation: float):
	gravity_scale = 0.0
	global_position = starting_position
	
	var dropout_direction = Vector2(-0.2, 1.0).rotated(player_rotation).normalized()
	var impuls = randf_range(IMPULSE_MIN_VALUE, IMPULSE_MAX_VALUE)
	
	apply_impulse(dropout_direction * impuls)
	apply_torque_impulse(randf_range(TORQUE_IMPULSE_MIN_VALUE, TORQUE_IMPULSE_MAX_VALUE))
	
	linear_damp = 4.0
	
	if muzzle_sprite:
		var tween = create_tween()
		tween.tween_property(muzzle_sprite, "position:y", -12.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(muzzle_sprite, "position:y", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		tween.tween_property(muzzle_sprite, "position:y", -4.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(muzzle_sprite, "position:y", 0.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	get_tree().create_timer(0.75).timeout.connect(func(): self.queue_free())
