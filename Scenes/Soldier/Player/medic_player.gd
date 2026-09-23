class_name MedicPlayer extends Player

signal check_can_heal()

@onready var healing_area_indicator: Sprite2D = $Healing_Area_Indicator
@onready var medic_apply_detection_shape_index: int = $Detection_Areas/Medic_Apply_Detection_Shape.get_index()

var allies_to_heal_nearby: Dictionary = {}

const HEALING_AMOUNT: float = 45.0
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
	is_queued_for_medic_healing = false
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

func _on_detection_areas_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	super._on_detection_areas_area_shape_entered(area_rid, area, area_shape_index, local_shape_index)
	match local_shape_index:
		medic_apply_detection_shape_index:
			_on_medic_apply_detection_shape_entered(area, area_shape_index)

func _on_detection_areas_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	super._on_detection_areas_area_shape_exited(area_rid, area, area_shape_index, local_shape_index)

	match local_shape_index:
		medic_apply_detection_shape_index:
			_on_medic_apply_detection_shape_exited(area, area_shape_index)

func _on_medic_apply_detection_shape_entered(area: Area2D, area_shape_index: int) -> void:
	if area.is_in_group("detection_areas") and area_shape_index == medic_detection_shape_index:
		var soldier: Player = area.get_parent()
		if soldier != self:
			allies_to_heal_nearby[soldier.soldier_id] = soldier
func _on_medic_apply_detection_shape_exited(area: Area2D, area_shape_index: int) -> void:
	if area.is_in_group("detection_areas") and area_shape_index == medic_detection_shape_index:
		var soldier: Player = area.get_parent()
		if soldier != self:
			allies_to_heal_nearby.erase(soldier.soldier_id)

#func _on_mouse_click(event: InputEvent):
	#pass
	##super._on_mouse_click(event)
	##for ally_id: String in allies_to_heal_nearby:
		##var ally: Player = allies_to_heal_nearby[ally_id]
		##if ally.check_is_healing_needed():
			##ally.healing_needed_sprite.visible = true
func on_soldier_killed():
	super.on_soldier_killed()
	healing_area_indicator.visible = false
	

func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
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
