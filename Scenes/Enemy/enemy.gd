extends Node2D
class_name Enemy

var num_seen_by: int = 0



func _ready() -> void:
	visible = false
	var tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(20,20), 60)

func show_enemy():
	visible = true
	num_seen_by +=1 

func hide_enemy():
	num_seen_by -= 1
	if num_seen_by == 0:
		visible = false
