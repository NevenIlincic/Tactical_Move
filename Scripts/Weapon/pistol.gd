class_name Pistol extends Weapon

func get_bullet_spawn_point(soldier: Soldier) -> Vector2:
	return soldier.pistol_bullet_spawn_point.global_position
