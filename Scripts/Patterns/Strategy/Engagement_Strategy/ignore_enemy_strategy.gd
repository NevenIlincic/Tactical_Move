class_name IgnoreEnemyStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	player.enemy_to_shoot = null
	player.current_weapon.change_enemy_to_shoot(null)
