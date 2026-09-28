class_name AchievementManager extends Node

var level: Level
var level_achievements: Dictionary

func set_level(_level: Level):
	level = _level
	level_achievements = Achievements.achievements[_level.LEVEL_NAME]

func check_is_completed():
	if not level_achievements["completed"]:
		level_achievements["completed"] = true

func check_is_soldier_lost():
	if not level_achievements["no_soldier_lost"]:
		if level.initial_num_players == level.get_alive_players().size():
			level_achievements["no_soldier_lost"] = true

func check_is_beach_ball_reached():
	if not level_achievements["beach_ball"]:
		if level.is_beach_ball_reached:
			level_achievements["beach_ball"] = true

func check_is_under_time(minutes: int, seconds: int):
	if level.total_passed_minutes > minutes:
		return
	elif level.total_passed_minutes < minutes:
		level_achievements["under_time"] = true
	else:
		if level.total_passed_time_seconds < seconds:
			level_achievements["under_time"] = true

func check_no_upgrades_applied():
	if not level_achievements["use_no_upgrades"]:
		if not level.is_upgrade_applied_once:
			level_achievements["use_no_upgrades"] = true

func check_no_healing_applied():
	if not level_achievements["use_no_heal"]:
		if not level.is_healing_applied_once:
			level_achievements["use_no_heal"] = true

func check_are_all_achievements_completed():
	if level_achievements["unlock_previous_achievements"]:
		return
		
	for key in level_achievements:
		if key == "unlock_previous_achievements":
			break
		if not level_achievements[key]:
			return 
	
	level_achievements["unlock_previous_achievements"] = true
	
