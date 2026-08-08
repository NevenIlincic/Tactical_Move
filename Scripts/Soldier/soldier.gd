#Base class for Player and Enemy
class_name Soldier extends Node2D

@onready var vision_polygon: SoldierVision = $Vision_Polygon

var is_killed: bool = false
var is_walking: bool = false
var follow_enemy_with_rotation = false
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
#UPGRADE/PERKS
var temporary_upgrades: Array[UpgradeData] = []
var permanent_upgrades: Array[UpgradeData] = []

#LAYOUT
@export var weapons: Array[Weapon]
@export var current_weapon: Weapon

func _ready() -> void:
	Signals.enemy_soldier_killed.connect(_on_enemy_soldier_killed)
	Signals.show_enemy.connect(_on_enemy_seen)
	Signals.hide_enemy.connect(_on_enemy_lost)

func _physics_process(delta: float) -> void:
	vision_polygon.update_vision()
	#print(is_walking, " ", has_enemies_in_sight())

func _on_enemy_soldier_killed(enemy_killed: Soldier, killed_by: Soldier):
	if enemies_in_sight.has(enemy_killed):
		enemies_in_sight.erase(enemy_killed)
	_on_enemy_lost(enemy_killed, killed_by)

func _select_next_enemy_to_shoot():
	var lowest_hp_enemy: Soldier = null
	var lowest_hp_value = INF
	
	for enemy: Soldier in enemies_in_sight.keys():
		var current_enemy_hp = enemy.HP
		if current_enemy_hp < lowest_hp_value:
			lowest_hp_value = current_enemy_hp
			lowest_hp_enemy = enemy
			
	enemy_to_shoot = lowest_hp_enemy

func is_soldier_walking() -> bool:
	return is_walking

func is_in_finished_state():
	return not is_soldier_walking() and not has_enemies_in_sight()
	
func has_enemies_in_sight() -> bool:
	if engagement_strategy is IgnoreEnemyStrategy:
		return false
	return not enemies_in_sight.is_empty()

func _on_enemy_seen(enemy: Soldier, soldier: Soldier):
	if self != soldier:
		return
	enemies_in_sight[enemy] = true
	on_engagement_action(enemy)
	_on_enemy_seen_extra(enemy)
func _on_enemy_seen_extra(enemy: Soldier):
	pass

func on_engagement_action(enemy: Soldier):
	if engagement_strategy:
		engagement_strategy.execute(self, enemy)

func _on_enemy_lost(enemy: Soldier, soldier: Soldier):
	if self != soldier or not enemy:
		return
	if enemies_in_sight.has(enemy):
		enemies_in_sight.erase(enemy)
	
	if enemies_in_sight.is_empty():
		enemy_to_shoot = null
		if not current_weapon.weapon_state is WeaponReloadState:
			current_weapon.change_weapon_state(WeaponIdleState.new())
		#point_to_look = initial_point
		#rotation_tween = create_tween()
		#do_initial_player_rotation(rotation_tween)
		#if rotation_tween and rotation_tween.is_valid():
			#await rotation_tween.finished
	else:
		if enemy == enemy_to_shoot:
			_select_next_enemy_to_shoot()
		if not (current_weapon.weapon_state is WeaponReloadState
			or current_weapon.weapon_state is WeaponShootState):
			current_weapon.change_weapon_state(WeaponShootState.new())
	
	current_weapon.change_enemy_to_shoot(enemy_to_shoot)
	
	_on_enemy_lost_extra(enemy)
	
	if enemy.is_killed:
		enemy.queue_free()

func _on_enemy_lost_extra(enemy: Soldier):
	pass

func do_while_action(delta: float):
	pass
