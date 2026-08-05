class_name WeaponReloadState extends WeaponState

func enter(weapon: Weapon):
	current_weapon = weapon
	print("REPETIRAM!")

func update(delta: float):
	pass
