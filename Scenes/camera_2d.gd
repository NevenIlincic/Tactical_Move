extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var is_dragging: bool = false

@onready var color_rect: ColorRect = $"../CanvasLayer2/CanvasGroup/ColorRect"
#
func _ready() -> void:
	_update_color_rect_transform()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("camera_drag"):
		is_dragging = true
	if Input.is_action_just_released("camera_drag"):
		is_dragging = false
	if Input.is_action_just_pressed("zoom_camera_in"):
		_zoom_in()
	if Input.is_action_just_pressed("zoom_camera_out"):
		_zoom_out()
	#if event is InputEventMouseButton:
		#if event.pressed:
			#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				#_zoom_in()
			#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				#_zoom_out()
			
	elif event is InputEventMouseMotion and is_dragging:
		position -= event.relative / zoom
		_update_color_rect_transform()

func _zoom_in() -> void:
	var new_zoom = zoom + Vector2(zoom_speed, zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	_update_color_rect_transform()
func _zoom_out() -> void:
	var new_zoom = zoom - Vector2(zoom_speed, zoom_speed)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	_update_color_rect_transform()
func _update_color_rect_transform() -> void:
	if not color_rect:
		return

	var viewport_size = get_viewport_rect().size
	
	var world_size = viewport_size / zoom
	
	color_rect.size = world_size
	
	color_rect.global_position = global_position - world_size / 2.0
