@abstract
class_name IWebSDK extends Node

signal rewarded_ad_watched()
signal interstitial_ad_watched()

var is_initialized: bool = false
var is_ad_block_enabled: bool = true
var num_tries_before_ad: int = 2

@abstract
func initialize_sdk();
@abstract
func show_rewarded_ad();
@abstract
func show_interstitial_ad();
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
func save_level_achievements();
@abstract
func save_option_values();
