class_name UpgradeData
extends Resource

enum UpgradeType{
	SPEED,
	HIT_CHANCE,
	MAX_AMMO,
	FIRE_RATE,
	REACTION_TIME
}

enum UpgradeReason{
	PLAYER_MOVING,
	LOW_HP,
	PERMANENT
}

@export var upgrade_type: UpgradeType
@export var bonus_value: float
@export var modifier_type: StatModifier.Type
@export var upgrade_reason: UpgradeReason

var applied_on_stat: Stat

var unique_id: String

func _init(value: float, u_type: UpgradeType, m_type: StatModifier.Type, u_reason: UpgradeReason) -> void:
	unique_id = str(Time.get_ticks_usec(), "_", randi())
	bonus_value = value
	upgrade_type = u_type
	modifier_type = m_type
	upgrade_reason = u_reason

func set_applied_on_stat(applied_stat: Stat):
	applied_on_stat = applied_stat
