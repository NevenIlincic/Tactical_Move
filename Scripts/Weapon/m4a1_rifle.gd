class_name m4a1Rifle extends Weapon

func get_bullet_spawn_point(soldier: Soldier) -> Vector2:
	return soldier.m4a1_rifle_bullet_spawn_point.global_position
