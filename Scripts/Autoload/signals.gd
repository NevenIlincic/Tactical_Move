extends Node

signal move_player(path_tiles: Array[Vector2i], tile_map: TileMapLayer)
signal set_selected_player(selected_player: Player)
signal deselect_player(player: Player)

signal stop_enemy_actions()

#SOLDIER SIGNALS
signal player_move_finished(soldier: Soldier) #When single soldier finishes his actions
signal player_move_continued(soldier: Soldier)
####
signal set_tile_to_solid(tile: Vector2i)

signal get_alive_enemies()

signal player_interaction_reset()
signal player_interaction()
#PLAYER VISION
signal report_enemy_seen(enemy: Soldier, player: Soldier)
signal show_enemy(enemy: Soldier)
signal hide_enemy(enemy: Soldier)
signal enemy_killed(enemy_killed: Enemy, killed_by: Player)

signal enemy_soldier_killed(enemy_killed: Soldier, killed_by: Soldier)

#ENEMY VISION
signal report_player_seen(player: Player)
signal shoot_player(enemy: Enemy, player:Player)
signal hide_player(enemy: Enemy, player: Player)
signal player_killed(enemy_killed: Player, killed_by: Enemy)

signal action_started()


#ACTIONS
signal open_upgrade_confirmation_dialog(upgrade_card: UpgradeCard)
signal open_upgrade_removal_confirmation_dialog(upgrade_card: UpgradeCard)
#UPGRADES
signal permanent_upgrade_applied(upgrade_card: UpgradeCard)
signal permanent_upgrade_removed(upgrade_card: UpgradeCard)
#STATS
signal update_ammo_stats_label(player: Player)
signal update_HP_bar_stats_label(player: Player)
signal engagement_strategy_changed(player: Player)
signal player_low_hp_applied(player: Player)

signal dark(points: Array)
