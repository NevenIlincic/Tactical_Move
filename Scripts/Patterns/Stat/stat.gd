class_name Stat
extends Resource

@export var base_value: float
var modifiers: Array[StatModifier] = []

func _init(p_base_value: float = 0.0):
	base_value = p_base_value

#Racuna vrednost na osnovu modifikatora koje sadrzi
func get_value() -> float:
	var final_value = base_value
	var percent_sum = 0.0
	
	for mod in modifiers:
		if mod.type == StatModifier.Type.FLAT:
			final_value += mod.value
		elif mod.type == StatModifier.Type.PERCENT:
			percent_sum += mod.value
	final_value *= (1.0 + percent_sum)
	
	return max(0.0, final_value)

func add_modifier(mod: StatModifier):
	modifiers.append(mod)

func remove_modifiers_from_source(source_obj: Object):
	modifiers = modifiers.filter(func(mod): return mod.source != source_obj)
