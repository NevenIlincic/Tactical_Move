extends Node

const M_4A_1_RIFLE_SOUND = preload("uid://c3ncljfia8w0c")
const BUTTON_SOUND = preload("uid://c6ouqh8rlq0bk")
const BUTTON_HOVER_SOUND = preload("uid://dh8wcx8p8d1kc")
const KILL_SOUND = preload("uid://bu34xvuh7o4lh")

#BACKGROUND MUSIC
const BACKGROUND_MUSIC_LEVEL = preload("uid://djailkikl7ma7")
const BACKGROUND_MUSIC_MENU_1 = preload("uid://clpks0xtiaws3")
var background_audio: AudioStreamPlayer

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

func play_background_music(stream_sound: Resource):
	if background_audio and background_audio.stream == stream_sound:
		return
	if not background_audio:
		background_audio = AudioStreamPlayer.new()
		background_audio.stream = stream_sound
		background_audio.bus = "Background_Music"
		background_audio.process_mode = Node.PROCESS_MODE_ALWAYS
		#audio.volume_db = volume
		if not background_audio.is_inside_tree():
			get_tree().root.add_child.call_deferred(background_audio)
			await background_audio.tree_entered
	else:
		background_audio.stream = stream_sound
	
	background_audio.play()
	background_audio.finished.connect(func(): 
		get_tree().create_timer(2.0).timeout.connect(
			func():
				background_audio.play()
		)
	)

func play_gun_shoot_sound():
	_play_sound(M_4A_1_RIFLE_SOUND, "Effects")

func play_upgrade_sound():
	_play_sound(BUTTON_SOUND, "HUD_Effects")

func play_button_hover_sound():
	_play_sound(BUTTON_HOVER_SOUND, "HUD_Effects")

func play_kill_sound():
	_play_sound(KILL_SOUND, "Effects")
