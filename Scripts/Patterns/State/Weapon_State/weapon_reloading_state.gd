class_name WeaponReloadState extends WeaponState

var reload_time_left: float

func enter(weapon: Weapon):
	current_weapon = weapon
	reload_time_left = current_weapon.weapon_stats.reload_time.get_value()

func update(delta: float):
	if reload_time_left > 0.0:
		reload_time_left -= delta
		if reload_time_left <= 0.0:
			on_reload_finished()
		

func on_reload_finished():
	if not current_weapon.weapon_state is WeaponShootState:
		current_weapon.weapon_stats.current_ammo.base_value = current_weapon.weapon_stats.max_ammo_capacity.get_value()
		print("RELOAD FINISHED! ", current_weapon.weapon_stats.current_ammo.get_value())
		current_weapon.change_weapon_state(WeaponShootState.new())
