class_name WeaponShootState extends WeaponState

var fire_timer: float

func enter(weapon: Weapon):
	current_weapon = weapon
	fire_timer = 0.0
	
func update(delta: float):
	check_has_ammo()
	fire_timer -= delta
	if fire_timer <= 0.0:
		shoot_target()
		fire_timer = 1.0 / current_weapon.fire_rate

func check_has_ammo():
	if current_weapon.current_ammo <= 0:
		current_weapon.change_weapon_state(WeaponReloadState.new())
		return 
func shoot_target():
	current_weapon.current_ammo -= 1
	current_weapon.enemy_to_shoot.HP -= current_weapon.damage
	print("NEPRIJATELJ POGODJEN: ", current_weapon.enemy_to_shoot.HP)
