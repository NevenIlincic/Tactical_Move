extends Node

const UPGRADE_CARD = preload("uid://c60uemqf7gdf2")

const UPGRADE_ICONS: Dictionary = {
	UpgradeData.UpgradeType.SPEED: preload("uid://dou87mqtbaj0r"),
	UpgradeData.UpgradeType.MAX_AMMO: preload("uid://c8g306bg7ys0b"),
	UpgradeData.UpgradeType.HIT_CHANCE: preload("uid://baqatp3dbiqcp"),
	UpgradeData.UpgradeType.FIRE_RATE: preload("uid://dau8h2jtb2w5a"),
	UpgradeData.UpgradeType.REACTION_TIME: preload("uid://c4enkpr2e4535"),
	UpgradeData.UpgradeType.RELOAD_TIME: preload("uid://dyfgry1avttjy"),
	UpgradeData.UpgradeType.WEAPON_DAMAGE: preload("uid://bl8n0a5b8nowm"),
	UpgradeData.UpgradeType.TRAVEL_DISTANCE: preload("uid://d1hablc0nksx6")
	
}

var available_permanent_upgrades: Dictionary = {} #{upgrade_id: UpgradeCard}

func create_upgrade_card(player: Soldier):
	var all_upgrade_types = UpgradeData.UpgradeType.values()
	var random_selected_type: UpgradeData.UpgradeType = all_upgrade_types.pick_random()
	var upgrade_data: UpgradeData
	var upgrade_reason: UpgradeData.UpgradeReason = UpgradeData.UpgradeReason.PERMANENT
	var bonus_value: float = 0.0
	var stat_to_apply_on: Stat
	
	match random_selected_type:
		UpgradeData.UpgradeType.SPEED:
			bonus_value = randf_range(1.0, 20.0)
			stat_to_apply_on = player.soldier_stats.speed
		UpgradeData.UpgradeType.MAX_AMMO:
			bonus_value = round(randf_range(1.0, 5.0))
			stat_to_apply_on = player.current_weapon.weapon_stats.max_ammo_capacity
		UpgradeData.UpgradeType.HIT_CHANCE:
			bonus_value = randf_range(0.1, 2.0)
			stat_to_apply_on = player.current_weapon.weapon_stats.hit_chance
		UpgradeData.UpgradeType.FIRE_RATE:
			bonus_value = randf_range(0.05, 0.2)
			stat_to_apply_on = player.current_weapon.weapon_stats.fire_rate
		UpgradeData.UpgradeType.REACTION_TIME:
			bonus_value = randf_range(-0.03, -0.1)
			stat_to_apply_on = player.soldier_stats.reaction_time
		UpgradeData.UpgradeType.RELOAD_TIME:
			bonus_value = randf_range(-0.05, -0.1)
			stat_to_apply_on = player.current_weapon.weapon_stats.reload_time
		UpgradeData.UpgradeType.WEAPON_DAMAGE:
			bonus_value = randf_range(1.0, 5.0)
			stat_to_apply_on = player.current_weapon.weapon_stats.damage
		UpgradeData.UpgradeType.TRAVEL_DISTANCE:
			bonus_value = randf_range(10.0, 35.0)
			stat_to_apply_on = player.soldier_stats.max_travel_distance
		
	bonus_value = snapped(bonus_value, 0.01)
	
	upgrade_data = UpgradeData.new(
			bonus_value, random_selected_type, StatModifier.Type.FLAT, upgrade_reason
		)
	upgrade_data.set_applied_on_stat(stat_to_apply_on)
	
	var new_upgrade_card: UpgradeCard = UPGRADE_CARD.instantiate()
	new_upgrade_card.unique_id = str(Time.get_ticks_usec(), "_", randi())
	new_upgrade_card.upgrade_data = upgrade_data
	new_upgrade_card.icon_texture = UPGRADE_ICONS[random_selected_type]
	new_upgrade_card.is_applied = false
	
	upgrade_data.set_upgrade_card(new_upgrade_card)
	available_permanent_upgrades[new_upgrade_card.unique_id] = new_upgrade_card
