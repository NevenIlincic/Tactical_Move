class_name TrainingCourseLevel extends Level

@onready var tutorial_labels_group: CanvasGroup = $CanvasLayer/Tutorial_Labels_Group

var tutorial_labels: Array
var tutorial_label_appearing_order: int = 0

func _ready() -> void:
	super._ready()
	for tutorial_label: TutorialTextDialog in tutorial_labels_group.get_children():
		tutorial_label.key_action_pressed.connect(_on_tutorial_button_pressed.bind(tutorial_label))
		tutorial_labels.append(tutorial_label)
	tutorial_labels[tutorial_label_appearing_order].visible = true
func _on_tutorial_button_pressed(tutorial_label: TutorialTextDialog):
	if tutorial_label_appearing_order == tutorial_label.appearing_order and check_is_satisfied(tutorial_label):
		tutorial_labels[tutorial_label_appearing_order].visible = false
		tutorial_label_appearing_order += 1
		if tutorial_label_appearing_order >= tutorial_labels.size():
			return
		tutorial_labels[tutorial_label_appearing_order].visible = true

func check_is_satisfied(tutorial_label: TutorialTextDialog) -> bool:
	if tutorial_label.dialog_text == "SELECT SOLDIER":
		if PlayerSelectionManager.selected_player != null:
			return true
		return false
	return true
