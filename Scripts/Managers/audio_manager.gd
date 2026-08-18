extends Node

const M_4A_1_RIFLE_SOUND = preload("uid://c3ncljfia8w0c")

var current_level: Level

func set_current_level(level: Level):
	current_level = level

func play_gun_shoot_sound():
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio.stream = M_4A_1_RIFLE_SOUND
	current_level.add_child(audio)
	audio.play()
	audio.finished.connect(func(): audio.queue_free())
