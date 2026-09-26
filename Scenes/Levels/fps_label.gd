class_name FPSLabel extends Label

func _ready() -> void:
	OptionVariables.show_fps_changed.connect(_on_fps_visibility_changed)

func _physics_process(delta: float) -> void:
	text = str("FPS: ", int(Engine.get_frames_per_second()))	

func _on_fps_visibility_changed(is_visible: bool):
	visible = is_visible
