extends Camera2D

var level: Level

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var is_dragging: bool = false

@onready var color_rect: ColorRect = $"../CanvasLayer2/CanvasGroup/ColorRect"

#MOBILE
var touch_points: Dictionary = {}
var last_pinch_distance: float = 0.0
@export var touch_zoom_sensitivity: float = 0.005
var is_touch_valid_for_drag: bool = false
var can_manipulate_camera: bool = false

#
func _ready() -> void:
	level = get_parent()
	level.can_manipulate_camera_signal.connect(_on_can_manipulate_camera_changed)

func _on_can_manipulate_camera_changed(can_manipulate: bool):
	can_manipulate_camera = can_manipulate

func _unhandled_input(event: InputEvent) -> void:
	if OptionVariables.check_is_device_pc():
		_handle_pc_input(event)
	else:
		if can_manipulate_camera:
			_handle_mobile_input(event)

func _handle_pc_input(event: InputEvent) -> void:
	if Input.is_action_pressed("camera_drag"):
		is_dragging = true
	if Input.is_action_just_released("camera_drag"):
		is_dragging = false
	if Input.is_action_just_pressed("zoom_camera_in"):
		_zoom_in()
	if Input.is_action_just_pressed("zoom_camera_out"):
		_zoom_out()
	if event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom
		_update_color_rect_transform()

func _handle_mobile_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			if touch_points.size() == 1:
				is_touch_valid_for_drag = true
		else:
			touch_points.erase(event.index)
			last_pinch_distance = 0.0
			is_touch_valid_for_drag = false # Ignorišemo skok preostalog prsta!

	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position

		if touch_points.size() == 1:
			if is_touch_valid_for_drag:
				position -= event.relative / zoom
				_update_color_rect_transform()
			else:
				is_touch_valid_for_drag = true

		elif touch_points.size() == 2:
			is_touch_valid_for_drag = false
			
			var points = touch_points.values()
			var current_distance: float = points[0].distance_to(points[1])

			if last_pinch_distance == 0.0:
				last_pinch_distance = current_distance
				return

			var distance_change: float = current_distance - last_pinch_distance
			
			if abs(distance_change) > 0.1:
				var zoom_delta: float = distance_change * touch_zoom_sensitivity
				var target_zoom: float = zoom.x + zoom_delta
				_set_zoom_level(target_zoom)
				last_pinch_distance = current_distance
				
func _zoom_in() -> void:
	_set_zoom_level(zoom.x + zoom_speed)

func _zoom_out() -> void:
	_set_zoom_level(zoom.x - zoom_speed)

func _set_zoom_level(target_zoom: float) -> void:
	var clamped_val: float = clamp(target_zoom, min_zoom, max_zoom)
	zoom = Vector2(clamped_val, clamped_val)
	_update_color_rect_transform()
func _update_color_rect_transform() -> void:
	if not color_rect:
		return

	var viewport_size = get_viewport_rect().size
	
	var world_size = viewport_size / zoom
	
	color_rect.size = world_size
	
	color_rect.global_position = global_position - world_size / 2.0
