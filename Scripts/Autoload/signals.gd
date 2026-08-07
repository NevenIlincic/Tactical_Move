extends Node


signal move_player(path_tiles: Array[Vector2i], tile_map: TileMapLayer)
signal set_selected_player(selected_player: Player)
signal deselect_player(player: Player)
signal player_move_finished() #When single soldier finishes his actions

signal set_tile_to_solid(tile: Vector2i)

signal get_alive_enemies()

#PLAYER VISION
signal report_enemy_seen(enemy: Enemy)
signal show_enemy(enemy: Enemy, player: Player)
signal hide_enemy(enemy: Enemy, player: Player)
signal enemy_killed(enemy_killed: Enemy, killed_by: Player)

signal enemy_soldier_killed(enemy_killed: Soldier, killed_by: Soldier)

#ENEMY VISION
signal report_player_seen(player: Player)
signal shoot_player(enemy: Enemy, player:Player)
signal hide_player(enemy: Enemy, player: Player)
signal player_killed(enemy_killed: Player, killed_by: Enemy)
