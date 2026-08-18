extends Node2D
class_name ConfirmDialog

@onready var dialog_text_label: Label = $Dialog_Text_Label

signal action_confirmed()
signal action_canceled()

func _on_yes_button_pressed() -> void:
	action_confirmed.emit()


func _on_no_button_pressed() -> void:
	action_canceled.emit()

func set_dialog_label_text(text: String):
	dialog_text_label.text = text
