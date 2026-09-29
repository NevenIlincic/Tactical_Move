@abstract
class_name IWebSDK extends Node

var is_initialized: bool = false

@abstract
func initialize_sdk();
@abstract
func show_rewarded_ad();
@abstract
func set_language();
@abstract
func set_game_ready();
@abstract
func level_started();
@abstract
func level_paused();
@abstract
func level_resumed();
@abstract
func level_completed();
@abstract
func level_failed();
@abstract
func save_data();
@abstract
func load_data();
@abstract
func delete_data();
@abstract 
func save_level_achievements()
