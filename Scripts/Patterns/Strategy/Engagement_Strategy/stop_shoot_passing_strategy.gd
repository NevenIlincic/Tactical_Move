class_name StopShootPassingStrategy extends EngagementStrategy

func execute(player: Player, enemy: Enemy):
	if not player.enemy_to_shoot:
		player.enemy_to_shoot = enemy
		player.current_weapon.change_enemy_to_shoot(enemy)
	if player.move_tween and player.move_tween.is_valid():
		player.move_tween.kill()
	player.is_walking = false
	player.reset_path()
	
	if not (player.current_weapon.weapon_state is WeaponReloadState
	or player.current_weapon.weapon_state is WeaponShootState):
		player.current_weapon.change_weapon_state(WeaponShootState.new())
