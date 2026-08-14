extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var is_dragging: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("camera_drag"):
		is_dragging = true
	if Input.is_action_just_released("camera_drag"):
		is_dragging = false
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_in()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_out()
			
	elif event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom

func _zoom_in() -> void:
	var new_zoom = zoom + Vector2(zoom_speed, zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _zoom_out() -> void:
	var new_zoom = zoom - Vector2(zoom_speed, zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
