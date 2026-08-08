class_name Enemy extends Soldier

#SCENE NODES
@onready var enemy_sprite: Sprite2D = $Enemy_Sprite
@export var HP: float = 100.0
#FOR PLAYER
var num_seen_by: int = 0

#FOR ENEMY
var point_to_look: Vector2

func show_enemy():
	visible = true
	num_seen_by +=1 

func hide_enemy():
	num_seen_by -= 1
	if num_seen_by == 0:
		visible = false

func _ready() -> void:
	#pass
	#visible = false
	engagement_strategy = StopShootFollowingStrategy.new()
	#connect_to_signals()
	#var tween = create_tween()
	#tween.tween_property(self, "global_position", Vector2(20,20), 40)

func do_while_action(delta: float):
	check_enemy_looking_at()

func do_actions():
	pass
func set_point_to_look(point):
	pass

func check_enemy_looking_at():
	if enemy_to_shoot:
		look_at(enemy_to_shoot.global_position)
	else:
		look_at(point_to_look)

#func connect_to_signals():
	#Signals.shoot_player.connect(_on_player_seen)
	#Signals.hide_player.connect(_on_player_lost)
#
#func _on_player_seen(enemy: Enemy, player: Player):
	#if enemy != self:
		#return
	#enemies_in_sight[player] = true
	#on_engagement_action(player)
	#
#func _on_player_lost(enemy: Enemy, player: Player):
	#if self != enemy or not player:
		#return
	#enemies_in_sight[player] = true
