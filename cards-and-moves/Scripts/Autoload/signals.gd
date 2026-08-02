extends Node


signal move_player(path_tiles: Array[Vector2i], tile_map: TileMapLayer)
signal set_selected_player(selected_player: Player)
signal deselect_player(player: Player)
