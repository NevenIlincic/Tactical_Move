class_name StopShootFollowingStrategy extends EngagementStrategy

func execute(player: Soldier, enemy: Soldier):
	if not player.enemy_to_shoot:
		player.enemy_to_shoot = enemy
		player.current_weapon.change_enemy_to_shoot(enemy)
	player.follow_enemy_with_rotation = true	
	player.set_point_to_look(enemy)
	
	stop_movement(player)
	
	if not (player.current_weapon.weapon_state is WeaponReloadState
	or player.current_weapon.weapon_state is WeaponShootState):
		player.current_weapon.change_weapon_state(WeaponShootState.new())

func stop_movement(player: Soldier):
	UpgradeManager.remove_moving_penalty(player)

	if player.move_tween and player.move_tween.is_valid():
		player.move_tween.kill()
	player.is_walking = false
	player.reset_path()
