class_name Weapon
extends Resource

@export var current_ammo: int
@export var max_ammo_capacity: int
@export var fire_rate: float
@export var damage: float
@export var hit_chance: float

var weapon_owner: Player
var weapon_state: WeaponState
var enemy_to_shoot: Enemy

func _init():
	change_weapon_state(WeaponIdleState.new())

func set_weapon_owner(player: Player):
	weapon_owner = player

func change_weapon_state(new_state: WeaponState):
	weapon_state = new_state
	weapon_state.enter(self)

func change_enemy_to_shoot(enemy: Enemy):
	enemy_to_shoot = enemy

func update(delta: float):
	weapon_state.update(delta)
