extends Node


signal move_player(path_tiles: Array[Vector2i], tile_map: TileMapLayer)
signal set_selected_player(selected_player: Player)
signal deselect_player(player: Player)
signal player_move_finished() #When single soldier finishes his actions

signal set_tile_to_solid(tile: Vector2i)

signal get_alive_enemies()

#VISION
signal report_enemy_seen(enemy: Enemy)
signal show_enemy(enemy: Enemy, player: Player)
signal hide_enemy(enemy: Enemy, players: Array[Player])
