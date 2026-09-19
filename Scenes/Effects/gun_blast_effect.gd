class_name GunBlastEffect extends GPUParticles2D

@onready var point_light_2d: PointLight2D = $PointLight2D

func do_effect(position: Vector2):
	global_position = position
	emitting = true
	point_light_2d.enabled = true

	var tween = create_tween()

	tween.tween_property(point_light_2d, "energy", 1.5, 0.05)
	tween.tween_property(point_light_2d, "energy", 1.0, 0.05)
	tween.tween_property(point_light_2d, "energy", 1.2, 0.05)
	
	tween.tween_callback(func():
		point_light_2d.enabled = false
		point_light_2d.energy = 1.0
	)
