class_name Door extends Control

var is_opened: bool = false

func top_indicator_activated():
	if not is_opened:
		is_opened = true
		rotation_degrees = 90

	#print(area.is_in_group("soldier"))
func bottom_indicator_activated():
	if not is_opened:
		is_opened = true
		rotation_degrees = -90


func _on_top_indicator_area_entered(area: Area2D) -> void:
	if area.is_in_group("door_detection_area"):
		top_indicator_activated()



func _on_bottom_indicator_area_entered(area: Area2D) -> void:
	if area.is_in_group("door_detection_area"):
		top_indicator_activated()
	
