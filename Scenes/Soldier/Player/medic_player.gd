class_name MedicPlayer extends Player

var allies_to_heal_nearby: Dictionary = {}

const HEALING_AMOUNT: float = 250.0

func _ready() -> void:
	super._ready()

func _pre_move_actions():
	super._pre_move_actions()
	do_healing()

##HEALING
func do_healing():
	for ally_id: String in allies_to_heal_nearby:
		var ally: Player = allies_to_heal_nearby[ally_id]
		if ally.is_queued_for_medic_healing:
			heal_player(ally)
func heal_player(player: Player):
	player.soldier_stats.HP.base_value = minf(player.soldier_stats.HP.base_value + HEALING_AMOUNT, player.soldier_stats.MAX_HP.base_value)
	player.healing_effect_cross.do_effect()
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
	if Input.is_action_just_pressed("healing") and is_selected and not allies_to_heal_nearby.is_empty():
		is_queued_for_medic_healing = !is_queued_for_medic_healing
		for ally_id: String in allies_to_heal_nearby:
			var ally: Player = allies_to_heal_nearby[ally_id]
			if is_queued_for_medic_healing:
				if ally.check_is_healing_needed():
					ally.healing_needed_sprite.visible = true
					ally.is_queued_for_medic_healing = true
			else:
				ally.healing_needed_sprite.visible = false
				ally.is_queued_for_medic_healing = false
