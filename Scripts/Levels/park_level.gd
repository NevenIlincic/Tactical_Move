class_name ParkLevel extends Level

func connect_to_signals():
	super.connect_to_signals()
	
func check_for_achivements():
	achievement_manager.check_is_completed()
	achievement_manager.check_is_under_time(0, 30)
	achievement_manager.check_is_soldier_lost()
	achievement_manager.check_no_upgrades_applied()
	achievement_manager.check_are_all_achievements_completed()
