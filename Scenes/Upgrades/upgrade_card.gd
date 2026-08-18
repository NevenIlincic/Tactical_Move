extends Control
class_name UpgradeCard

var unique_id: String
var upgrade_data: UpgradeData
var icon_texture: CompressedTexture2D
var is_applied: bool
@onready var upgrade_value_label: Label = $Upgrade_Value_Label

@onready var upgrade_icon: Sprite2D = $Upgrade_Icon

func _ready() -> void:
	upgrade_icon.texture = icon_texture
	set_upgrade_value_label()

func set_upgrade_value_label():
	var upgrade_value: float = upgrade_data.bonus_value
	print(upgrade_data.upgrade_type)
	if upgrade_value > 0.0:
		upgrade_value_label.text = str("+", upgrade_value)
	else:
		upgrade_value_label.text = str(upgrade_value)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not is_applied and PlayerSelectionManager.selected_player:
			Signals.permanent_upgrade_applied.emit(self)
			
