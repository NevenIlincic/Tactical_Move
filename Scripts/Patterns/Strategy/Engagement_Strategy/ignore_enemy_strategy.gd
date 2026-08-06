class_name IgnoreEnemyStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	player.enemy_to_shoot = null
