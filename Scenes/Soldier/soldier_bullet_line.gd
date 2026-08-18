class_name SoldierBulletLine extends Line2D

const M_4A_1_RIFLE_SOUND = preload("uid://c3ncljfia8w0c")

func draw_bullet(starting_position: Vector2, bullet_hit_point: Vector2):
	var start_points = PackedVector2Array([starting_position, starting_position])
	var end_points = PackedVector2Array([starting_position, bullet_hit_point])
	
	AudioManager.play_gun_shoot_sound()
	points = start_points
	var tween: Tween = create_tween()
	
	tween.tween_property(self, "points", end_points, 0.05)
	tween.tween_callback(func(): points = start_points)

	#audio.finished.connect(func(): audio.queue_free())
