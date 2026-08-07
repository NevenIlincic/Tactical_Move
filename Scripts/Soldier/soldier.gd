#Base class for Player and Enemy
class_name Soldier extends Node2D

var is_killed: bool = false
var is_walking: bool = false
var enemy_to_shoot: Soldier
var enemies_in_sight: Dictionary = {} #{Soldier: true}
@export var soldier_stats: PlayerStats:
	set(value):
		soldier_stats = value
		if soldier_stats:
			soldier_stats = soldier_stats.duplicate(true)
			soldier_stats.speed = Stat.new(soldier_stats.speed.base_value)
			soldier_stats.reaction_time = Stat.new(soldier_stats.reaction_time.base_value)
			soldier_stats.max_travel_distance = Stat.new(soldier_stats.max_travel_distance.base_value)
			soldier_stats.HP = Stat.new(soldier_stats.HP.base_value)
			
var engagement_strategy: EngagementStrategy

func _ready() -> void:
	Signals.enemy_soldier_killed.connect(_on_enemy_soldier_killed)

func _on_enemy_soldier_killed(enemy_killed: Soldier, killed_by: Soldier):
	if enemies_in_sight.has(enemy_killed):
		enemies_in_sight.erase(enemy_killed)
	_on_enemy_lost(enemy_killed, killed_by)

func is_soldier_walking() -> bool:
	return is_walking

func is_in_finished_state():
	return not is_soldier_walking() and not has_enemies_in_sight()
	
func has_enemies_in_sight() -> bool:
	return not enemies_in_sight.is_empty()
	
func on_enemy_soldier_killed(enemy: Soldier, killed_by: Soldier):
	pass
func _on_enemy_lost(enemy_lost_from_sight: Soldier, who_lost_sight: Soldier):
	pass
