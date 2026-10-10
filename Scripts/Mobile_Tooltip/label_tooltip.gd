class_name CustomTooltip extends Label
@onready var video_menu: VideoMenu

@export var option: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	video_menu = get_tree().get_first_node_in_group("video_menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gui_input(event: InputEvent) -> void:
	if not OptionVariables.check_is_device_pc():
		if event is InputEventScreenTouch and event.pressed:
			video_menu._on_tooltip_activated(self, get_global_mouse_position())
