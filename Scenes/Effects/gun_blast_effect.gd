class_name GunBlastEffect extends GPUParticles2D

@onready var point_light_2d: PointLight2D = $PointLight2D

func do_effect(position: Vector2):
	global_position = position
	emitting = true
	point_light_2d.enabled = true
	
	# Kreiramo Tween za treperenje
	var tween = create_tween()
	
	# Primer: svetlost menja energiju sa 1 na 0.2 nekoliko puta u toku trajanja čestica
	# Pretpostavka je da efekat traje npr. 0.2 ili 0.3 sekunde (prilagodi po potrebi)
	tween.tween_property(point_light_2d, "energy", 1.5, 0.05)
	tween.tween_property(point_light_2d, "energy", 1.0, 0.05)
	tween.tween_property(point_light_2d, "energy", 1.2, 0.05)
	
	# Kada se efekat završi, gasi svetlo i vrati energiju na normalu
	finished.connect(func(): 
		point_light_2d.enabled = false
		point_light_2d.energy = 1.0 # vratimo na podrazumevanu vrednost za sledeći put
	, CONNECT_ONE_SHOT)
