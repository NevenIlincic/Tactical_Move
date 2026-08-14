extends Node2D

@onready var player_avatar: Sprite2D = $Player_Avatar
@onready var player_name_label: Label = $Player_Name_Label
#AMMO
@onready var ammo_label: Label = $Ammo_Label
#HP
@onready var hp_bar: TextureProgressBar = $HP_Bar
@onready var hp_percentage_label: Label = $HP_Bar/HP_Percentage_Label
#MOVE SPEED
@onready var move_speed_label: Label = $Move_Speed_Label
#RELOAD SPEED
@onready var reload_time_label: Label = $Reload_Icon/Reload_Time_Label
#REACTION TIME
@onready var reaction_time_label: Label = $Reaction_Time_Node/Reaction_Time_Label
#MAX TRAVEL DISTANCE
@onready var max_distance_label: Label = $Max_Distance_Node/Max_Distance_Label

func _ready() -> void:
	Signals.set_selected_player.connect(_on_selected_player)
	Signals.deselect_player.connect(_on_deselect_player)
	Signals.action_started.connect(_on_action_started)
	hide_stats()
	

func _on_selected_player(player: Player):
	player_avatar.texture = player.player_avatar
	player_name_label.text = player.player_name
	ammo_label.text = str(int(player.current_weapon.weapon_stats.current_ammo.get_value()), "/", int(player.current_weapon.weapon_stats.max_ammo_capacity.get_value()))
	hp_bar.value = player.soldier_stats.HP.base_value
	hp_percentage_label.text = str(int(hp_bar.value), "%")
	move_speed_label.text = str(player.soldier_stats.speed.get_value())
	reload_time_label.text = str(player.current_weapon.weapon_stats.reload_time.get_value(), "s")
	reaction_time_label.text = str(player.soldier_stats.reaction_time.get_value(), "s")
	max_distance_label.text = str(player.soldier_stats.max_travel_distance.get_value())
	show_stats()

func _on_deselect_player():
	hide_stats()

func _on_action_started():
	hide_stats()


func hide_stats():
	visible = false
func show_stats():
	visible = true
