#Base class for Player and Enemy
class_name Soldier extends Node2D

@onready var vision_polygon: SoldierVision = $Vision_Polygon
@onready var hitbox_collision_shape: CollisionShape2D = $Hitbox/Hitbox_Collision_Shape

var is_in_active_state: bool = false
var is_killed: bool = false
var is_walking: bool = false
var follow_enemy_with_rotation = false

var enemy_to_shoot: Soldier
var enemies_in_sight: Dictionary = {} #{Soldier: true}
var after_move_looking_point #Vector2/null
var point_to_look #Vector2/Soldier
var player_path: Array[Vector2]

var rotation_tween: Tween
var move_tween: Tween

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
	connect_to_signals()
	player_path.append(global_position)
	
	if not weapons.is_empty():
		current_weapon = weapons[0]
		current_weapon.set_weapon_owner(self)
	
func _physics_process(delta: float) -> void:
	vision_polygon.update_vision()
	#print(is_walking, " ", has_enemies_in_sight())

func connect_to_signals():
	Signals.enemy_soldier_killed.connect(_on_enemy_soldier_killed)
	Signals.show_enemy.connect(_on_enemy_seen)
	Signals.hide_enemy.connect(_on_enemy_lost)

func _on_enemy_soldier_killed(enemy_killed: Soldier, killed_by: Soldier):
	enemy_killed.hitbox_collision_shape.disabled = true
	if enemies_in_sight.has(enemy_killed):
		enemies_in_sight.erase(enemy_killed)
	_on_enemy_lost(enemy_killed, self)
	enemy_killed.queue_free()
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

func is_in_finished_state() -> bool:
	return not is_soldier_walking() and not has_enemies_in_sight()
	
func has_enemies_in_sight() -> bool:
	if engagement_strategy is IgnoreEnemyStrategy:
		return false
	return not enemies_in_sight.is_empty()

func check_soldier_has_action():
	if len(player_path) > 1 or point_to_look:
		Signals.player_move_continued.emit(self)
func set_after_move_looking_point(point: Vector2):
	after_move_looking_point = point
func reset_after_move_looking_point():
	after_move_looking_point = null

func set_player_looking_at():
	if point_to_look:
		if check_is_point_to_look_vector():	
			look_at(point_to_look)
		else:
			look_at(point_to_look.global_position)

func check_is_enemy_in_sight():
	if enemy_to_shoot:
		if follow_enemy_with_rotation:
			set_point_to_look(enemy_to_shoot)

func check_is_point_to_look_vector() -> bool:
	return point_to_look is Vector2

func reset_path():
	player_path.clear()
	player_path.append(global_position)
	reset_after_move_looking_point()

func _on_enemy_seen(enemy: Soldier, soldier: Soldier):
	if self != soldier:
		return
	if is_in_finished_state():
		Signals.player_move_continued.emit(self)
	
	if not enemies_in_sight.has(enemy):
		enemies_in_sight[enemy] = true
		enemy.when_spotted()
	on_engagement_action(enemy)
func _on_enemy_seen_extra(enemy: Soldier):
	pass

func on_engagement_action(enemy: Soldier):
	if engagement_strategy:
		engagement_strategy.execute(self, enemy)

func _on_enemy_lost(enemy: Soldier, soldier: Soldier):
	if self != soldier or not enemy:
		return
	if enemies_in_sight.has(enemy):
		enemy.when_escaped()
		enemies_in_sight.erase(enemy)
		
	if enemies_in_sight.is_empty():
		enemy_to_shoot = null
		if not current_weapon.weapon_state is WeaponReloadState:
			current_weapon.change_weapon_state(WeaponIdleState.new())
		
		await get_tree().create_timer(0.2).timeout
		if is_in_finished_state():
			Signals.player_move_finished.emit(self)
	else:
		if enemy == enemy_to_shoot:
			_select_next_enemy_to_shoot()
		if not (current_weapon.weapon_state is WeaponReloadState
			or current_weapon.weapon_state is WeaponShootState):
			current_weapon.change_weapon_state(WeaponShootState.new())
	
	current_weapon.change_enemy_to_shoot(enemy_to_shoot)
	
	#_on_enemy_lost_extra(enemy)
	
	#if enemy.is_killed:
		#enemy.queue_free()

func do_soldier_rotation(tween: Tween):
	#var target_point: Vector2 = global_position
	if not point_to_look:
		tween.kill()
		return
	
	var target_point = point_to_look
	var	target_angle = global_position.angle_to_point(target_point)
	var start_angle = rotation
	
	tween.tween_method(
		func(weight: float): rotation = lerp_angle(start_angle, target_angle, weight),
		0.0, 1.0, 0.15
	)
	await tween.finished.connect(_on_rotation_stop)

func _move():
	is_walking = true
	rotation_tween = create_tween()
	move_tween = create_tween()
	do_soldier_rotation(rotation_tween)
	do_movement(move_tween)
	if move_tween and move_tween.is_valid():
		await move_tween.finished
	if rotation_tween and rotation_tween.is_valid():
		await rotation_tween.finished
	is_walking = false
func do_movement(tween: Tween):
	if len(player_path) <= 1:
		tween.kill()
		return
	var current_position = global_position	
	for target_position in player_path:
		var distance = current_position.distance_to(target_position)
		var duration = distance / soldier_stats.speed.get_value()
		tween.tween_property(self, "global_position", target_position, duration)
		
		current_position = target_position
	await tween.finished.connect(_on_move_stop)

func _on_rotation_stop():
	pass


func _on_move_stop():
	if after_move_looking_point:
		point_to_look = after_move_looking_point
		var tween: Tween = create_tween()
		do_soldier_rotation(tween)
		await tween.finished
		reset_after_move_looking_point()
		set_player_looking_at()

func _on_actions_finished():
	player_path.clear()
	point_to_look = null
	player_path.append(global_position)
	if is_in_finished_state():
		Signals.player_move_finished.emit(self)

#TEMPLATE METHODS
func do_while_action(delta: float):
	check_is_enemy_in_sight()	
	set_player_looking_at()
	if current_weapon:
		current_weapon.update(delta)
	do_while_action_extra()

func do_actions():
	_pre_move_actions()
	await _move()
	_on_actions_finished()
	

#HAS TO BE OVERRIDEN
func when_spotted(): pass
func when_escaped(): pass
func _on_enemy_lost_extra(enemy: Soldier): pass
func set_point_to_look(point): pass
func do_while_action_extra(): pass
func _pre_move_actions(): pass
