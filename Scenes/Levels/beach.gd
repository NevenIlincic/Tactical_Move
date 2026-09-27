class_name BeachLevel extends Level

var is_beach_ball_reached: bool = false

func check_for_achivements():
	achievement_manager.check_is_completed()
	achievement_manager.check_is_under_time(1, 0)
	achievement_manager.check_is_soldier_lost()
	achievement_manager.check_is_beach_ball_reached()
	achievement_manager.check_are_all_achievements_completed()

func _on_beach_ball_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("beach_ball"):
		is_beach_ball_reached = true


func _on_beach_ball_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("beach_ball"):
		is_beach_ball_reached = false
