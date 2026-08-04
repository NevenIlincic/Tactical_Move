extends Line2D
class_name CustomLine

func reset_path():
	points = points.slice(0,1)

func _get_line_length() -> float:
	var total_length: float = 0.0
	for i in range(points.size() - 1):
		total_length += points[i].distance_to(points[i + 1])
		
	return total_length
