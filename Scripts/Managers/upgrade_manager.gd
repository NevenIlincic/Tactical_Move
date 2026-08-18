extends Node2D

func _get_player_stat_to_upgrade(upgrade_type: UpgradeData.UpgradeType, player: Player) -> Stat:
	var stat_to_apply_on: Stat
	match upgrade_type:
		UpgradeData.UpgradeType.SPEED:
			stat_to_apply_on = player.soldier_stats.speed
		UpgradeData.UpgradeType.MAX_AMMO:
			stat_to_apply_on = player.current_weapon.weapon_stats.max_ammo_capacity
		UpgradeData.UpgradeType.HIT_CHANCE:
			stat_to_apply_on = player.current_weapon.weapon_stats.hit_chance
		UpgradeData.UpgradeType.FIRE_RATE:
			stat_to_apply_on = player.current_weapon.weapon_stats.fire_rate
		UpgradeData.UpgradeType.REACTION_TIME:
			stat_to_apply_on = player.soldier_stats.reaction_time
		UpgradeData.UpgradeType.RELOAD_TIME:
			stat_to_apply_on = player.current_weapon.weapon_stats.reload_time
		UpgradeData.UpgradeType.WEAPON_DAMAGE:
			stat_to_apply_on = player.current_weapon.weapon_stats.damage
		UpgradeData.UpgradeType.TRAVEL_DISTANCE:
			stat_to_apply_on = player.soldier_stats.max_travel_distance
	
	return stat_to_apply_on

#PERMANENT PERKS
func apply_permanent_perk(upgrade_card: UpgradeCard, player: Player):
	var upgrade_data: UpgradeData = upgrade_card.upgrade_data
	var stat_to_apply_on: Stat = _get_player_stat_to_upgrade(upgrade_data.upgrade_type, player)
	var stat_modifier: StatModifier = StatModifier.new(
		upgrade_data.bonus_value, upgrade_data.modifier_type, upgrade_data
	)
	upgrade_data.set_applied_on_stat(stat_to_apply_on)
	stat_to_apply_on.add_modifier(stat_modifier)
	player.permanent_upgrades[upgrade_card.unique_id] = upgrade_card
	
	if UpgradeCardsManager.available_permanent_upgrades.has(upgrade_card.unique_id):
		UpgradeCardsManager.available_permanent_upgrades.erase(upgrade_card.unique_id)

func remove_permanent_perk(upgrade_card: UpgradeCard, player: Player):
	var upgrade_data: UpgradeData = upgrade_card.upgrade_data
	remove_perk(upgrade_data)
	if player.permanent_upgrades.has(upgrade_card.unique_id):
		player.permanent_upgrades.erase(upgrade_card.unique_id)
		upgrade_card.queue_free()

#Applied when player is moving	
func apply_movement_penalty_perk(player: Soldier):
	if len(player.player_path) > 1: #If player is moving
		var hit_chance_perk: UpgradeData = UpgradeData.new(
			-0.1, UpgradeData.UpgradeType.HIT_CHANCE, StatModifier.Type.PERCENT, UpgradeData.UpgradeReason.PLAYER_MOVING
		)
		hit_chance_perk.set_applied_on_stat(player.current_weapon.weapon_stats.hit_chance)
		var hit_chance_mod: StatModifier = StatModifier.new(
			hit_chance_perk.bonus_value, hit_chance_perk.modifier_type, hit_chance_perk
		)
		player.current_weapon.weapon_stats.hit_chance.add_modifier(hit_chance_mod)
		player.temporary_upgrades.append(hit_chance_perk)

func remove_temporary_perks(player: Soldier):
	var perks_to_remove: Array[UpgradeData] = []
	for temporary_perk in player.temporary_upgrades:
		remove_perk(temporary_perk)
		perks_to_remove.append(temporary_perk)
	for perk in perks_to_remove:
		player.temporary_upgrades.erase(perk)


func remove_perk(perk: UpgradeData):
	if perk.applied_on_stat:
		perk.applied_on_stat.remove_modifiers_from_source(perk)

#Triggers when soldier stops moving
func remove_moving_penalty(player: Soldier):
	var moving_perk: UpgradeData = null
	for perk in player.temporary_upgrades:
		if perk.upgrade_reason == UpgradeData.UpgradeReason.PLAYER_MOVING:
			moving_perk = perk
			remove_perk(perk)
			break
	player.temporary_upgrades.erase(moving_perk)

#Triggers when player heals above 30% HP
func remove_low_hp_penalty(player: Soldier):
	var perks_to_remove: Array[UpgradeData] = []
	for perk in player.temporary_upgrades:
		if perk.upgrade_reason == UpgradeData.UpgradeReason.LOW_HP:
			perks_to_remove.append(perk)
			remove_perk(perk)
	
	for perk in perks_to_remove:
		player.temporary_upgrades.erase(perk)

#Triggers when player gets below 30% HP (SPEED -15%, HIT_CHANCE -25%, REACTION_TIME +0.5s, RELOAD_TIME: +20%)
func apply_low_hp_penalty(player: Soldier):
	#SPEED
	var lower_speed_perk: UpgradeData = UpgradeData.new(
		-0.15, UpgradeData.UpgradeType.SPEED, StatModifier.Type.PERCENT, UpgradeData.UpgradeReason.LOW_HP
	)
	var lower_speed_mod: StatModifier = StatModifier.new(
		lower_speed_perk.bonus_value, lower_speed_perk.modifier_type, lower_speed_perk
	)
	player.soldier_stats.speed.add_modifier(lower_speed_mod)
	lower_speed_perk.set_applied_on_stat(player.soldier_stats.speed)
	#HIT CHANCE
	var lower_hit_chance_perk: UpgradeData = UpgradeData.new(
		-0.25, UpgradeData.UpgradeType.HIT_CHANCE, StatModifier.Type.PERCENT, UpgradeData.UpgradeReason.LOW_HP
	)
	var lower_hit_chance_mod: StatModifier = StatModifier.new(
		lower_hit_chance_perk.bonus_value, lower_hit_chance_perk.modifier_type, lower_hit_chance_perk
	)
	player.current_weapon.weapon_stats.hit_chance.add_modifier(lower_hit_chance_mod)
	lower_hit_chance_perk.set_applied_on_stat(player.current_weapon.weapon_stats.hit_chance)
	#REACTION TIME
	var longer_reaction_time_perk: UpgradeData = UpgradeData.new(
		0.5, UpgradeData.UpgradeType.HIT_CHANCE, StatModifier.Type.FLAT, UpgradeData.UpgradeReason.LOW_HP
	)
	var longer_reaction_time_mod: StatModifier = StatModifier.new(
		longer_reaction_time_perk.bonus_value, longer_reaction_time_perk.modifier_type, longer_reaction_time_perk
	)
	player.soldier_stats.reaction_time.add_modifier(longer_reaction_time_mod)
	longer_reaction_time_perk.set_applied_on_stat(player.soldier_stats.reaction_time)
	#RELOAD TIME
	var longer_reload_time_perk: UpgradeData = UpgradeData.new(
		0.2, UpgradeData.UpgradeType.RELOAD_TIME, StatModifier.Type.PERCENT, UpgradeData.UpgradeReason.LOW_HP
	)
	var longer_reload_time_mod: StatModifier = StatModifier.new(
		longer_reload_time_perk.bonus_value, longer_reload_time_perk.modifier_type, longer_reload_time_perk
	)
	player.current_weapon.weapon_stats.reload_time.add_modifier(longer_reload_time_mod)
	longer_reload_time_perk.set_applied_on_stat(player.current_weapon.weapon_stats.reload_time)
	
	player.temporary_upgrades.append(lower_speed_perk)
	player.temporary_upgrades.append(lower_hit_chance_perk)
	player.temporary_upgrades.append(longer_reaction_time_perk)
	player.temporary_upgrades.append(longer_reload_time_perk)
