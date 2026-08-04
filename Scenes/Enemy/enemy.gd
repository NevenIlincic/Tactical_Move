extends Node2D
class_name Enemy

var num_seen_by: int = 0

func _process(delta: float) -> void:
	global_position.x -= 10.0 * delta

func _ready() -> void:
	visible = false

func show_enemy():
	visible = true
	num_seen_by +=1 

func hide_enemy():
	num_seen_by -= 1
	if num_seen_by == 0:
		visible = false
