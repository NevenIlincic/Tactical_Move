class_name PlayerPathLine extends CustomLine

var MAX_LENGTH: float = 1000.0

func check_can_add_point(point: Vector2) -> bool:
	var line_length: float = _get_line_length()
	var new_line_length: float = line_length + point.distance_to(points[-1]) 
	if new_line_length < MAX_LENGTH:
		return true
	return false
