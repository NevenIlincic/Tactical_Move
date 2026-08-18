extends Control
class_name UpgradeCard

var unique_id: String
var upgrade_data: UpgradeData
var icon_texture: CompressedTexture2D
var is_applied: bool

#SCENE NODES
@onready var upgrade_value_label: Label = $Upgrade_Value_Label
@onready var upgrade_icon: Sprite2D = $Upgrade_Icon
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_animation_loop_finished: bool = false
var is_mouse_hovered: bool = false

func _ready() -> void:
	upgrade_icon.texture = icon_texture
	set_upgrade_value_label()

func set_upgrade_value_label():
	var upgrade_value: float = upgrade_data.bonus_value
	var percentage_sign: String = ""
	var upgrade_modifier_type: StatModifier.Type = upgrade_data.modifier_type
	
	if upgrade_modifier_type == StatModifier.Type.PERCENT:
		percentage_sign = "%"
		upgrade_value *= 100
		
	if upgrade_value > 0.0:
		upgrade_value_label.text = str("+", upgrade_value, percentage_sign)
	else:
		upgrade_value_label.text = str(upgrade_value, percentage_sign)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if PlayerSelectionManager.selected_player:
			if not is_applied:
				Signals.open_upgrade_confirmation_dialog.emit(self)
			else:
				Signals.permanent_upgrade_removed.emit(self)


func _on_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK)
	animation_player.play("card_shine_effect")
	is_mouse_hovered = true
	
func _on_mouse_exited() -> void:
	is_mouse_hovered = false
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
func _on_animation_loop_finished():
	if not is_mouse_hovered:
		is_animation_loop_finished = true
		animation_player.stop()
		animation_player.seek(0)
func _on_animation_loop_started():
	is_animation_loop_finished = false
