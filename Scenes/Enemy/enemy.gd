extends Node2D
class_name Enemy

var num_seen_by: int = 0

@export var HP: float = 100.0
@onready var enemy_sprite: Sprite2D = $Enemy_Sprite
var is_killed: bool = false

func _ready() -> void:
	#pass
	visible = false
	#var tween = create_tween()
	#tween.tween_property(self, "global_position", Vector2(20,20), 40)

func show_enemy():
	visible = true
	num_seen_by +=1 

func hide_enemy():
	num_seen_by -= 1
	if num_seen_by == 0:
		visible = false
