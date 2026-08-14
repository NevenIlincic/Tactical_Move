extends Node2D

@onready var player_avatar: Sprite2D = $Player_Avatar

func _ready() -> void:
	Signals.set_selected_player.connect(_on_selected_player)
	Signals.deselect_player.connect(_on_deselect_player)
	hide_stats()
func _on_selected_player(player: Player):
	player_avatar.texture = player.player_avatar
	show_stats()

func _on_deselect_player():
	hide_stats()

func hide_stats():
	visible = false
func show_stats():
	visible = true
