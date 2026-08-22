extends Node

const M_4A_1_RIFLE_SOUND = preload("uid://c3ncljfia8w0c")
const BUTTON_SOUND = preload("uid://c6ouqh8rlq0bk")
const BUTTON_HOVER_SOUND = preload("uid://dh8wcx8p8d1kc")

var current_level: Level

func set_current_level(level: Level):
	current_level = level

func play_gun_shoot_sound():
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio.stream = M_4A_1_RIFLE_SOUND
	#current_level.add_child(audio)
	get_tree().root.add_child(audio)
	audio.play()
	audio.finished.connect(func(): audio.queue_free())

func play_upgrade_sound():
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio.stream = BUTTON_SOUND
	get_tree().root.add_child(audio)
	audio.play()
	audio.finished.connect(func(): audio.queue_free())

func play_button_hover_sound():
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio.stream = BUTTON_HOVER_SOUND
	get_tree().root.add_child(audio)
	audio.play()
	audio.finished.connect(func(): audio.queue_free())
