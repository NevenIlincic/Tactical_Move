class_name StopShootPassingStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	player.enemy_to_shoot = enemy
	if player.move_tween and player.move_tween.is_valid():
		player.move_tween.kill()
	player.is_walking = false
	player.reset_path()
