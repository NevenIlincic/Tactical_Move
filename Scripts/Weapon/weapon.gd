class_name Weapon
extends Resource

@export var weapon_stats: WeaponStats
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
