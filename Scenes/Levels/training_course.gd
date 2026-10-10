class_name TrainingCourseLevel extends Level

@onready var tutorial_labels_group: CanvasGroup = $CanvasLayer/Tutorial_Labels_Group
@onready var keith_regular: Player = $Keith_Regular
@onready var start_room_door: Door = $Start_Room_Door

var tutorial_labels: Array
var tutorial_label_appearing_order: int = 0

@onready var animation_sprite: AnimatedSprite2D = $CanvasLayer/Animation_Sprite
@onready var video_background_rect: ColorRect = $CanvasLayer/Video_Background_Rect

var tutorial_animations: Dictionary = {
	0: "camera_drag",
	1: "camera_zoom_in",
	2: "camera_zoom_out",
	3: "camera_reset_position",
	4: "select_soldier",
	6: "draw_path",
	7: "look_after_move",
	8: "look_while_moving",
	9: "reset_point_while_moving",
	10: "reset_point_after_move",
	11: "reset_path",
	12: "open_strategy_menu",
	13: "toggle_healing",
	14: "open_upgrade_menu"
}

func _ready() -> void:
	super._ready()
	controller_button.visible = false
	animation_sprite.play(tutorial_animations[tutorial_label_appearing_order])
	for tutorial_label: TutorialTextDialog in tutorial_labels_group.get_children():
		tutorial_label.key_action_released.connect(_on_tutorial_button_pressed.bind(tutorial_label))
		#tutorial_label.key_action_released.connect(_on_tutorial_button_pressed.bind(tutorial_label))
		tutorial_labels.append(tutorial_label)
	tutorial_labels[tutorial_label_appearing_order].visible = true
	
	keith_regular.soldier_stats.HP.base_value = 100.0


func disconnect_from_signals():
	super.disconnect_from_signals()
	for tutorial_label: TutorialTextDialog in tutorial_labels_group.get_children():
		if tutorial_label.key_action_released.is_connected(_on_tutorial_button_pressed.bind(tutorial_label)):
			tutorial_label.key_action_released.disconnect(_on_tutorial_button_pressed.bind(tutorial_label))

func _on_tutorial_button_pressed(tutorial_label: TutorialTextDialog):
	if tutorial_label_appearing_order == tutorial_label.appearing_order and check_is_satisfied(tutorial_label):
		tutorial_labels[tutorial_label_appearing_order].visible = false
		tutorial_label_appearing_order += 1
		if tutorial_animations.has(tutorial_label_appearing_order):
			animation_sprite.visible = true
			video_background_rect.visible = true
			animation_sprite.play(tutorial_animations[tutorial_label_appearing_order])
		else:
			animation_sprite.visible = false
			video_background_rect.visible = false

		if tutorial_label_appearing_order >= tutorial_labels.size():
			start_room_door.can_open = true
			return
		if tutorial_label_appearing_order >= 15:
			animation_sprite.stop()
			animation_sprite.visible = false
			video_background_rect.visible = false
			controller_button.visible = true
		tutorial_labels[tutorial_label_appearing_order].visible = true
		tutorial_labels[tutorial_label_appearing_order].get_action_bind_key()

func check_is_satisfied(tutorial_label: TutorialTextDialog) -> bool:
	#if tutorial_label.dialog_text == "SELECT SOLDIER":
		#if PlayerSelectionManager.selected_player != null:
			#return true
		#return false
	return true

func check_for_achivements():
	achievement_manager.check_is_completed()
	achievement_manager.check_is_under_time(0, 7)
	achievement_manager.check_is_soldier_lost()
	achievement_manager.check_are_all_achievements_completed()

	
