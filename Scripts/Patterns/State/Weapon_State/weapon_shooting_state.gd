class_name WeaponShootState extends WeaponState

var fire_timer: float

func enter(weapon: Weapon):
	current_weapon = weapon
	fire_timer = current_weapon.weapon_owner.soldier_stats.reaction_time.get_value()
	
func update(delta: float):
	if current_weapon.weapon_stats.current_ammo.get_value() <= 0:
		current_weapon.change_weapon_state(WeaponReloadState.new())
		return
	fire_timer -= delta
	if fire_timer <= 0.0 and check_can_shoot_target():
		shoot_target()
		fire_timer = 1.0 / current_weapon.weapon_stats.fire_rate.get_value()

func shoot_target():
	current_weapon.weapon_stats.current_ammo.base_value -= 1.0
	current_weapon.enemy_to_shoot.soldier_stats.HP.base_value -= current_weapon.weapon_stats.damage.get_value()
	print(current_weapon.weapon_owner, " PUCAO NA: ", current_weapon.enemy_to_shoot )
	if current_weapon.enemy_to_shoot.soldier_stats.HP.base_value <= 0.0:
		current_weapon.enemy_to_shoot.is_killed = true
		on_target_killed(current_weapon.enemy_to_shoot, current_weapon.weapon_owner)
		#current_weapon.weapon_owner.enemy_to_shoot.queue_free()
		#current_weapon.enemy_to_shoot = null

func check_can_shoot_target():
	return current_weapon.enemy_to_shoot and not current_weapon.enemy_to_shoot.is_killed

func on_target_killed(enemy_killed: Soldier, killed_by: Soldier):
	Signals.enemy_soldier_killed.emit(enemy_killed, killed_by)
