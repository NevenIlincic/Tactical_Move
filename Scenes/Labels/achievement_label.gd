class_name AchievementLabel extends Control

var achievement: String
var level_name: String

@onready var locked_achievemnt_texture_rect: TextureRect = $Locked_Achievemnt_Texture_Rect
@onready var unlocked_achievemnt_texture_rect: TextureRect = $Unlocked_Achievemnt_Texture_Rect
@onready var achievement_label: Label = $Achievement_Label

func initialize_achivement_node(_level_name: String, _achivement: String):
	level_name = _level_name
	achievement = _achivement
	set_achivement_text()
	check_is_achievement_locked()

func check_is_achievement_locked():
	if Achievements.achievements.has(level_name):
		if Achievements.achievements[level_name][achievement]:
			unlock_achievement()
		else:
			lock_achievement()

func lock_achievement():
	locked_achievemnt_texture_rect.visible = true
	unlocked_achievemnt_texture_rect.visible = false
func unlock_achievement():
	unlocked_achievemnt_texture_rect.visible = true
	locked_achievemnt_texture_rect.visible = false

func set_achivement_text():
	var base_text: String = Achievements.return_achivement_base_text(achievement)
	achievement_label.text = base_text
	if achievement == "under_time":
		var additional_text: String = set_under_time()
		achievement_label.text = str(base_text, " ", additional_text)
func set_under_time() -> String:
	var additional_text: String
	match level_name:
		"Training Course":
			additional_text = " 7s"
		"Beach":
			additional_text = " 1m"
		"House":
			additional_text = " 1m 30s"
		"Parking Lot":
			additional_text = " 3m"
				
	return additional_text
