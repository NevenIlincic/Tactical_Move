class_name PlaygamaSDK extends IWebSDK

func initialize_sdk():
	is_initialized = true
	Bridge.platform.connect("audio_state_changed", Callable(self, "_on_audio_state_changed"))
	Bridge.platform.connect("pause_state_changed", Callable(self, "_on_pause_state_changed"))
	check_is_game_audio_muted()
	load_data()

func set_language():
	Bridge.platform.language
func show_rewarded_ad():
	pass
func set_game_ready():
	Bridge.platform.send_message(Bridge.PlatformMessage.GAME_READY)
func level_started():
	Bridge.platform.send_message(Bridge.PlatformMessage.LEVEL_STARTED)
func level_paused():
	Bridge.platform.send_message(Bridge.PlatformMessage.LEVEL_PAUSED)
func level_resumed():
	Bridge.platform.send_message(Bridge.PlatformMessage.LEVEL_RESUMED)
func level_completed():
	Bridge.platform.send_message(Bridge.PlatformMessage.LEVEL_COMPLETED)
func level_failed():
	Bridge.platform.send_message(Bridge.PlatformMessage.LEVEL_FAILED)

func _on_audio_state_changed(is_enabled):
	var is_muted: bool = not is_enabled
	set_audio_mute(is_muted)
func _on_pause_state_changed(is_paused):
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.paused = is_paused
		set_audio_mute(is_paused)
func check_is_game_audio_muted():
	var is_muted: bool = not Bridge.platform.is_audio_enabled
	var master_bus_index: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, is_muted)
func set_audio_mute(is_muted: bool):
	var master_bus_index: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, is_muted)

func save_data():
	Bridge.storage.set({
	"level": "dungeon_123",
	"is_tutorial_completed": true,
	"coins": 42
	}, Callable(self, "_on_storage_set_completed"))
	
func load_data():
	var key: String = "Level_Achievements"
	Bridge.storage.get(key, Callable(self, "_on_level_achievements_storage_get_completed"))

func delete_data():
	Bridge.storage.delete("Level_Achievements", Callable(self, "_on_storage_delete_completed"))

func save_level_achievements():
	var key: String = "Level_Achievements"
	var data_to_save: Dictionary = Achievements.achievements
	var data_json: String = JSON.stringify(data_to_save)
	Bridge.storage.set(key, data_json, Callable(self, "_on_storage_set_completed"))
func _on_storage_set_completed(success: bool):
	pass

func _on_level_achievements_storage_get_completed(success, data):
	if success:
		if data is String:
			var json = JSON.new()
			var parse_result = json.parse(data)
			if parse_result == OK:
				var achivements_dict: Dictionary = json.data
				Achievements.achievements = achivements_dict
