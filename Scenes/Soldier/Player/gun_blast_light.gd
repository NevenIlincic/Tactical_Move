extends PointLight2D

@onready var gun_blast_effect: GunBlastEffect = $"../GunBlastEffect"

func _ready() -> void:
	gun_blast_effect.effect_triggered.connect(_on_gun_blast_effect_triggered)

func _on_gun_blast_effect_triggered(light_position: Vector2):
	global_position = light_position
	enabled = true
	var tween = create_tween()
	tween.tween_property(self, "energy", 1.5, 0.05)
	tween.tween_property(self, "energy", 1.0, 0.05)
	tween.tween_property(self, "energy", 1.2, 0.05)
	
	tween.tween_callback(func():
		enabled = false
		energy = 1.0
	)
