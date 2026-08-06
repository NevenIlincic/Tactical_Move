class_name MoveShootPassingStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	if not player.enemy_to_shoot:
		player.enemy_to_shoot = enemy
		player.current_weapon.change_enemy_to_shoot(enemy)
		
	player.follow_enemy_with_rotation = false	
	if not (player.current_weapon.weapon_state is WeaponReloadState
	or player.current_weapon.weapon_state is WeaponShootState):
		player.current_weapon.change_weapon_state(WeaponShootState.new())
