class_name Door extends Control

var is_opened: bool = false
@onready var door_slam_sound: AudioStreamPlayer2D = $Door_Slam_Sound

func top_indicator_activated():
	if not is_opened:
		is_opened = true
		rotation_degrees = 90
		door_slam_sound.play()

	#print(area.is_in_group("soldier"))
func bottom_indicator_activated():
	if not is_opened:
		is_opened = true
		rotation_degrees = -90
		door_slam_sound.play()


func _on_top_indicator_area_entered(area: Area2D) -> void:
	if area.is_in_group("door_detection_area"):
		top_indicator_activated()



func _on_bottom_indicator_area_entered(area: Area2D) -> void:
	if area.is_in_group("door_detection_area"):
		top_indicator_activated()
	
