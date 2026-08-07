class_name EnemyStopShootStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	if not enemy.player_to_shoot:
		enemy.player_to_shoot = player
