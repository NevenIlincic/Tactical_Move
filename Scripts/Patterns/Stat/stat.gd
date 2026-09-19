class_name Stat
extends Resource

@export var base_value: float
@export var max_value: float
var modifiers: Array[StatModifier] = []

func _init(p_base_value: float = 0.0, p_max_value: float = 1000.0):
	base_value = p_base_value
	max_value = p_max_value

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
	
	if max_value != 0.0 and final_value > max_value:
		final_value = max_value

	return max(0.0, final_value)

func add_modifier(mod: StatModifier):
	modifiers.append(mod)

func remove_modifiers_from_source(source_obj: Object):
	modifiers = modifiers.filter(func(mod): return mod.source != source_obj)
