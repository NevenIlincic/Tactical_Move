class_name Enemy extends Soldier

#SCENE NODES
@onready var enemy_sprite: Sprite2D = $Enemy_Sprite
@export var HP: float = 100.0
#FOR PLAYER
var num_seen_by: int = 0

func when_spotted():
	visible = true
	num_seen_by += 1 

func when_escaped():
	num_seen_by -= 1
	if num_seen_by == 0:
		visible = false

func _ready() -> void:
	super._ready()
	#visible = false
	engagement_strategy = StopShootFollowingStrategy.new()
	point_to_look = Vector2.ZERO

func set_point_to_look(point):
	point_to_look = point
	if not check_is_point_to_look_vector():
		point_to_look = point.global_position


func _pre_move_actions():
	#ADD LOGIC FOR PLAYER MOVEMENT (probably will use built-in A* algorithm)
	#var i: int = randi() % 500 + 1
	#player_path.append(Vector2(i, i)) #Only for test 
	Signals.player_move_finished.emit(self)
	#check_soldier_has_action()
	
func check_enemy_looking_at():
	if enemy_to_shoot:
		look_at(enemy_to_shoot.global_position)
	else:
		look_at(point_to_look)

func _on_enemy_lost_extra(enemy: Soldier) -> void:
	pass
	#print("OVDE")
	#hide_enemy()
