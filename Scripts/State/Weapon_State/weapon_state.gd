@abstract
class_name WeaponState
extends Resource

var current_weapon: Weapon

@abstract
func enter(weapon: Weapon);

@abstract
func update(delta: float)
