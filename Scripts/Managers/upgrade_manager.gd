extends Node2D

func apply_temporary_perks(player: Player):
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
		
func remove_temporary_perks(player: Player):
	var perks_to_remove: Array[UpgradeData] = []
	for temporary_perk in player.temporary_upgrades:
		remove_perk(temporary_perk)
		perks_to_remove.append(temporary_perk)
	for perk in perks_to_remove:
		player.temporary_upgrades.erase(perk)
		
func remove_perk(perk: UpgradeData):
	if perk.applied_on_stat:
		perk.applied_on_stat.remove_modifiers_from_source(perk)

func remove_moving_penalty(player: Player):
	var moving_perk: UpgradeData = null
	for perk in player.temporary_upgrades:
		if perk.upgrade_reason == UpgradeData.UpgradeReason.PLAYER_MOVING:
			moving_perk = perk
			remove_perk(perk)
			break
	player.temporary_upgrades.erase(moving_perk)

#Triggers when player heals above 30% HP
func remove_low_hp_penalty(player: Player):
	var perks_to_remove: Array[UpgradeData] = []
	for perk in player.permanent_upgrades:
		if perk.upgrade_reason == UpgradeData.UpgradeReason.LOW_HP:
			perks_to_remove.append(perk)
			remove_perk(perk)
	
	for perk in perks_to_remove:
		player.permanent_upgrades.erase(perk)

#Triggers when player gets below 30% HP (SPEED -15%, HIT_CHANCE -25%, REACTION_TIME +0.5s)
func apply_low_hp_penalty(player: Player):
	#SPEED
	var lower_speed_perk: UpgradeData = UpgradeData.new(
		-0.15, UpgradeData.UpgradeType.SPEED, StatModifier.Type.PERCENT, UpgradeData.UpgradeReason.LOW_HP
	)
	var lower_speed_mod: StatModifier = StatModifier.new(
		lower_speed_perk.bonus_value, lower_speed_perk.modifier_type, lower_speed_perk
	)
	player.player_stats.speed.add_modifier(lower_speed_mod)
	lower_speed_perk.set_applied_on_stat(player.player_stats.speed)
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
	player.player_stats.reaction_time.add_modifier(longer_reaction_time_mod)
	longer_reaction_time_perk.set_applied_on_stat(player.player_stats.reaction_time)
	
	player.permanent_upgrades.append(lower_speed_perk)
	player.permanent_upgrades.append(lower_hit_chance_perk)
	player.permanent_upgrades.append(longer_reaction_time_perk)
