class_name MedicPlayer extends Player

signal check_can_heal()

@onready var healing_area_indicator: Sprite2D = $Healing_Area_Indicator

var allies_to_heal_nearby: Dictionary = {}

const HEALING_AMOUNT: float = 250.0
const HEALING_TIMEOUT_AMOUNT: float = 30.0
var healing_timeout: float = 0.0
var can_heal: bool = true

var is_timeout_active: bool = true

func _ready() -> void:
	super._ready()
	check_can_heal.connect(_check_is_healing_available)

func _pre_move_actions():
	super._pre_move_actions()
	is_timeout_active = true
	if is_queued_for_medic_healing:
		do_healing()

func _check_is_healing_available(action_duration: float):
	if not is_timeout_active:
		return
	is_timeout_active = false
	
	print("OVDE")
	healing_timeout -= action_duration
	if healing_timeout <= 0.0:
		can_heal = true
		healing_area_indicator.visible = true
		healing_timeout = 0.0


##HEALING
func do_healing():
	healing_timeout = HEALING_TIMEOUT_AMOUNT
	healing_area_indicator.visible = false
	can_heal = false
	for ally_id: String in allies_to_heal_nearby:
		var ally: Player = allies_to_heal_nearby[ally_id]
		if ally.is_queued_for_medic_healing:
			heal_player(ally)
func heal_player(player: Player):
	player.soldier_stats.HP.base_value = minf(player.soldier_stats.HP.base_value + HEALING_AMOUNT, player.soldier_stats.MAX_HP.base_value)
	player.healing_effect_cross.do_effect()
	player.healing_needed_sprite.visible = false
	if player.soldier_stats.HP.base_value / player.soldier_stats.MAX_HP.base_value >= 0.3:
		UpgradeManager.remove_low_hp_penalty(player)
###

func _on_medic_apply_area_body_entered(body: Node2D) -> void:
	var soldier = body.get_parent()
	if soldier != self and body.is_in_group("player_hitbox") and soldier is Player:
		allies_to_heal_nearby[soldier.soldier_id] = soldier

func _on_medic_apply_area_body_exited(body: Node2D) -> void:
	var soldier = body.get_parent()
	if soldier != self and body.is_in_group("player_hitbox") and soldier is Player:
		allies_to_heal_nearby.erase(soldier.soldier_id)

#func _on_mouse_click(event: InputEvent):
	#pass
	##super._on_mouse_click(event)
	##for ally_id: String in allies_to_heal_nearby:
		##var ally: Player = allies_to_heal_nearby[ally_id]
		##if ally.check_is_healing_needed():
			##ally.healing_needed_sprite.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("healing") and is_selected and not allies_to_heal_nearby.is_empty() and can_heal:
		var i: int = 0
		is_queued_for_medic_healing = !is_queued_for_medic_healing
		for ally_id: String in allies_to_heal_nearby:
			var ally: Player = allies_to_heal_nearby[ally_id]
			if is_queued_for_medic_healing:
				if ally.check_is_healing_needed():
					ally.healing_needed_sprite.visible = true
					ally.is_queued_for_medic_healing = true
					i += 1
			else:
				ally.healing_needed_sprite.visible = false
				ally.is_queued_for_medic_healing = false
		if i == 0:
			is_queued_for_medic_healing = false
