extends ColorRect

func _ready() -> void:
	Signals.dark.connect(update_darkness_mask)

func update_darkness_mask(global_points: Array):
	var mat = material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("points", global_points)
		mat.set_shader_parameter("points_count", global_points.size())
