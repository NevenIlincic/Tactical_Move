class_name TrainingCourseLevel extends Level

@onready var tutorial_labels_group: CanvasGroup = $CanvasLayer/Tutorial_Labels_Group
@onready var keith_regular: Player = $Keith_Regular
@onready var start_room_door: Door = $Start_Room_Door

var tutorial_labels: Array
var tutorial_label_appearing_order: int = 0

func _ready() -> void:
	super._ready()
	for tutorial_label: TutorialTextDialog in tutorial_labels_group.get_children():
		tutorial_label.key_action_released.connect(_on_tutorial_button_pressed.bind(tutorial_label))
		#tutorial_label.key_action_released.connect(_on_tutorial_button_pressed.bind(tutorial_label))
		tutorial_labels.append(tutorial_label)
	tutorial_labels[tutorial_label_appearing_order].visible = true
	
	keith_regular.soldier_stats.HP.base_value = 200.0


func _on_tutorial_button_pressed(tutorial_label: TutorialTextDialog):
	if tutorial_label_appearing_order == tutorial_label.appearing_order and check_is_satisfied(tutorial_label):
		tutorial_labels[tutorial_label_appearing_order].visible = false
		tutorial_label_appearing_order += 1
		if tutorial_label_appearing_order >= tutorial_labels.size():
			start_room_door.can_open = true
			return
		tutorial_labels[tutorial_label_appearing_order].visible = true
		tutorial_labels[tutorial_label_appearing_order].get_action_bind_key()

func check_is_satisfied(tutorial_label: TutorialTextDialog) -> bool:
	#if tutorial_label.dialog_text == "SELECT SOLDIER":
		#if PlayerSelectionManager.selected_player != null:
			#return true
		#return false
	return true
