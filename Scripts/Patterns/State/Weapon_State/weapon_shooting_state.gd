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
	if current_weapon.weapon_owner is Enemy:
		print(current_weapon.weapon_owner.vision_polygon.bullet_hit_point)
	draw_bullet()
	current_weapon.weapon_stats.current_ammo.base_value -= 1.0
	current_weapon.enemy_to_shoot.soldier_stats.HP.base_value -= current_weapon.weapon_stats.damage.get_value()
	if check_is_target_hit():
		if current_weapon.weapon_owner:
			current_weapon.enemy_to_shoot.when_been_shoot_at(current_weapon.weapon_owner)
		if current_weapon.enemy_to_shoot is Player:
			Signals.update_HP_bar_stats_label.emit(current_weapon.enemy_to_shoot)
		if current_weapon.enemy_to_shoot.soldier_stats.HP.base_value <= 0.0:
			on_target_killed(current_weapon.enemy_to_shoot, current_weapon.weapon_owner)
		
	if current_weapon.weapon_owner is Player:
		Signals.update_ammo_stats_label.emit(current_weapon.weapon_owner)
func check_can_shoot_target():
	return current_weapon.enemy_to_shoot and not current_weapon.enemy_to_shoot.is_killed

func on_target_killed(enemy_killed: Soldier, killed_by: Soldier):
	enemy_killed.is_killed = true
	killed_by.vision_polygon.bullet_hit_point = null
	killed_by.when_escaped()
	current_weapon.enemy_to_shoot = null
	Signals.enemy_soldier_killed.emit(enemy_killed, killed_by)
	if killed_by is Player:
		UpgradeCardsManager.create_upgrade_card()

func draw_bullet():
	if current_weapon.weapon_owner and current_weapon.weapon_owner.vision_polygon.bullet_hit_point:
		var starting_position = current_weapon.get_bullet_spawn_point(current_weapon.weapon_owner)
		var target_position: Vector2 = current_weapon.weapon_owner.vision_polygon.bullet_hit_point
		current_weapon.weapon_owner.bullet_line.draw_bullet(starting_position, target_position)

func check_is_target_hit():
	var probability: float = randf() * 100
	return probability <= current_weapon.weapon_stats.hit_chance.get_value()
