class_name StatModifier
extends Resource

enum Type {
	FLAT, 
	PERCENT
}

var value: float
var type: Type
var source: Object #Player, Weapon

func _init(p_value: float, p_type: Type, p_source: Object = null):
	value = p_value
	type = p_type
	source = p_source
