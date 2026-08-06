class_name MoveShootFollowingStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	player.enemy_to_shoot = enemy
	player.follow_enemy_with_rotation = true
	if player.rotation_tween and player.rotation_tween.is_valid():
		player.rotation_tween.kill()
