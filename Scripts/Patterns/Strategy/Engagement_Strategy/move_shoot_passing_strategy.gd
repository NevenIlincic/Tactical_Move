class_name MoveShootPassingStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	player.enemy_to_shoot = enemy
	player.follow_enemy_with_rotation = false
