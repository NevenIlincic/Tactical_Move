extends Control

@onready var slider: HSlider = $Slider
@onready var slider_value_label: Label = $Slider_Value_Label

@export var bus_name: String
var bus_index: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	set_slider_value()
	connect_to_signals()

func set_slider_value():
	var db_value: float = AudioServer.get_bus_volume_db(bus_index)
	var linear_value: float = db_to_linear(db_value)
	slider.value = linear_value * 100.0
	slider_value_label.text = str(int(slider.value), "%")
	
func connect_to_signals():
	slider.value_changed.connect(_on_slider_value_changed)
	slider.drag_ended.connect(_on_slider_drag_ended)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_slider_value_changed(value: float):
	slider_value_label.text = str(int(value), "%")

func _on_slider_drag_ended(has_value_changed: bool):
	if has_value_changed:
		var linear_value: float = slider.value / 100.0
		var db_value: float = linear_to_db(linear_value)
		
		AudioServer.set_bus_volume_db(bus_index, db_value)
		AudioServer.set_bus_mute(bus_index, linear_value == 0)
	else:
		print("OSTALO ISTO!")
