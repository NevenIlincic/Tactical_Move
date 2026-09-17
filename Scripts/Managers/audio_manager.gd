extends Node

const M_4A_1_RIFLE_SOUND = preload("uid://c3ncljfia8w0c")
const BUTTON_SOUND = preload("uid://c6ouqh8rlq0bk")
const BUTTON_HOVER_SOUND = preload("uid://dh8wcx8p8d1kc")
const KILL_SOUND = preload("uid://bu34xvuh7o4lh")

var current_level: Level

func set_current_level(level: Level):
	current_level = level

func _play_sound(stream_sound: Resource, bus_name: String, volume: float = 10.0):
	var audio: AudioStreamPlayer = AudioStreamPlayer.new()
	audio.stream = stream_sound
	audio.bus = bus_name
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	#audio.volume_db = volume
	get_tree().root.add_child(audio)
	audio.play()
	audio.finished.connect(func(): audio.queue_free())

func play_gun_shoot_sound():
	_play_sound(M_4A_1_RIFLE_SOUND, "Effects")

func play_upgrade_sound():
	_play_sound(BUTTON_SOUND, "HUD_Effects")

func play_button_hover_sound():
	_play_sound(BUTTON_HOVER_SOUND, "HUD_Effects")

func play_kill_sound():
	_play_sound(KILL_SOUND, "Effects")
