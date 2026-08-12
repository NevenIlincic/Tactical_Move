class_name MoveShootFollowingStrategy extends EngagementStrategy

func execute(player: Soldier, enemy: Soldier):
	if not player.enemy_to_shoot:
		player.enemy_to_shoot = enemy
		player.current_weapon.change_enemy_to_shoot(enemy)
	
	player.set_point_to_look(enemy)
	#if player.rotation_tween and player.rotation_tween.is_valid():
		#player.rotation_tween.kill()
	player.follow_enemy_with_rotation = true
	if not (player.current_weapon.weapon_state is WeaponReloadState
	or player.current_weapon.weapon_state is WeaponShootState):
		player.current_weapon.change_weapon_state(WeaponShootState.new())
