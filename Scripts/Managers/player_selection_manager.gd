extends Node
#class_name PlayerSelectionManager

var selected_player: Player

signal player_selection_changed(old_player: Player, new_selected_player: Player)
signal player_deselected(deselected_player: Player)

#func _init() -> void:
	#Signals.set_selected_player.connect(select_player)
	#Signals.deselect_player.connect(deselect_player)
func _ready() -> void:
	Signals.set_selected_player.connect(select_player)
	Signals.deselect_player.connect(deselect_player)


func deselect_player():
	if selected_player:
		player_deselected.emit(selected_player)
		selected_player.is_selected = false
		selected_player.player_sprite.modulate.a = 1.0
		selected_player = null

func select_player(new_selected_player: Player):
	var old_player: Player = selected_player
	deselect_player()
	selected_player = new_selected_player
	selected_player.player_sprite.modulate.a = 0.5
	if old_player:
		player_selection_changed.emit(old_player, selected_player)
