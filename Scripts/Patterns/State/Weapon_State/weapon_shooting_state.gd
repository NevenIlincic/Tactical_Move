class_name WeaponShootState extends WeaponState

var fire_timer: float

func enter(weapon: Weapon):
	current_weapon = weapon
	fire_timer = 0.0
	
func update(delta: float):
	if current_weapon.weapon_stats.current_ammo.get_value() <= 0:
		current_weapon.change_weapon_state(WeaponReloadState.new())
		return
	fire_timer -= delta
	if fire_timer <= 0.0:
		shoot_target()
		fire_timer = 1.0 / current_weapon.weapon_stats.fire_rate.get_value()

func shoot_target():
	current_weapon.weapon_stats.current_ammo.base_value -= 1.0
	current_weapon.enemy_to_shoot.HP -= current_weapon.weapon_stats.damage.get_value()
	print("NEPRIJATELJ POGODJEN: ", current_weapon.enemy_to_shoot.HP)
