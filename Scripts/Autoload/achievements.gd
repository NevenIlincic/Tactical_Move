extends Node

var achievements: Dictionary = {
	"Training Course": {
		"completed": false,
		"under_time": false,
		"no_soldier_lost": false,
		"unlock_previous_achievements": false
	},
	"Beach": {
		"completed": false,
		"under_time": false,
		"no_soldier_lost": false,
		"beach_ball": false,
		"use_no_upgrades": false,
		"unlock_previous_achievements": false
	},
	"House": {
		"completed": false,
		"under_time": false,
		"no_soldier_lost": false,
		"use_no_upgrades": false,
		"use_no_heal": false,
		"unlock_previous_achievements": false
	},
	"Parking Lot": {
		"completed": false,
		"under_time": false,
		"no_soldier_lost": false,
		"use_no_upgrades": false,
		"use_no_heal": false,
		"unlock_previous_achievements": false
	},
	"Park": {
		"completed": false,
		"under_time": false,
		"no_soldier_lost": false,
		"use_no_upgrades": false,
		"unlock_previous_achievements": false
	}
}

func return_achivement_base_text(achievement: String) -> String:
	var base_text: String
	match achievement:
		"completed":
			base_text = "Complete level"
		"under_time":
			base_text = "Complete level under"
		"no_soldier_lost":
			base_text = "Don't lose soldier"
		"use_no_upgrades":
			base_text = "Don't apply an upgrade"
		"beach_ball":
			base_text = "Complete level with beach ball in area"
		"use_no_heal":
			base_text = "Don't use medic healing"
		"unlock_previous_achievements":
			base_text = "Unlock all other achievements"
	return base_text
