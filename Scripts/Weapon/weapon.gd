class_name Weapon
extends Resource

@export var weapon_stats: WeaponStats:
	set(value):
		weapon_stats = value
		if weapon_stats:
			weapon_stats = weapon_stats.duplicate(true)
			weapon_stats.current_ammo = Stat.new(weapon_stats.current_ammo.base_value)
			weapon_stats.max_ammo_capacity = Stat.new(weapon_stats.max_ammo_capacity.base_value)
			weapon_stats.damage = Stat.new(weapon_stats.damage.base_value)
			weapon_stats.fire_rate = Stat.new(weapon_stats.fire_rate.base_value)
			weapon_stats.hit_chance = Stat.new(weapon_stats.hit_chance.base_value)

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
