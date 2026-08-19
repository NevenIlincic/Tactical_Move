extends Control

@onready var player_avatar: Sprite2D = $Player_Avatar
@onready var player_name_label: Label = $Player_Name_Label
#AMMO
@onready var ammo_label: Label = $Ammo_Node/Ammo_Label
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
#WEAPON FIRE RATE
@onready var fire_rate_label: Label = $Fire_Rate_Node/Fire_Rate_Label
#WEAPON DAMAGE
@onready var damage_label: Label = $Damage_Node/Damage_Label
#WEAPON HIT CHANCE
@onready var hit_chance_label: Label = $Hit_Chance_Node/Hit_Chance_Label
#WEAPON SPRITE
@onready var pistol_sprite: Sprite2D = $Pistol_Sprite
@onready var m4a1_rifle_sprite: Sprite2D = $m4a1_rifle_sprite

#GRID CONTAINER
@onready var grid_container_applied_upgrades: GridContainer = $Grid_Container_Applied_Upgrades

#ENGAGEMENT STRATEGY ICON
var engagement_strategy_icons: Dictionary = {
	Player.EngagementRules.IGNORE: preload("uid://cfst0l2a1ts0o"),
	Player.EngagementRules.STOP_AND_SHOT_IN_PASSING: preload("uid://b0hk5gucidtjh"),
	Player.EngagementRules.STOP_AND_SHOT_FOLLOWING: preload("uid://y3yekhjq5544"),
	Player.EngagementRules.MOVE_AND_SHOT_IN_PASSING: preload("uid://bmxe4wqdu1rfb"),
	Player.EngagementRules.MOVE_AND_SHOT_FOLLOWING: preload("uid://uahkyrcb1vcj")
}
@onready var engagement_strategy_icon: Sprite2D = $Engagement_Strategy_Icon

func _ready() -> void:
	Signals.set_selected_player.connect(_on_selected_player)
	Signals.deselect_player.connect(_on_deselect_player)
	Signals.action_started.connect(_on_action_started)
	Signals.permanent_upgrade_applied.connect(_on_permanent_upgrade_applied)
	Signals.permanent_upgrade_removed.connect(_on_permanent_upgrade_removed)
	Signals.update_ammo_stats_label.connect(_on_player_shoot)
	Signals.update_HP_bar_stats_label.connect(_on_player_hit)
	Signals.engagement_strategy_changed.connect(_on_engagement_strategy_changed)
	hide_stats()
	

func _on_selected_player(player: Player):
	update_stats_labels(player)
	set_weapon_sprite(player.current_weapon)
	set_applied_upgrades(player)
	_on_engagement_strategy_changed(player)
	show_stats()

func update_stats_labels(player: Player):
	player_avatar.texture = player.player_avatar
	player_name_label.text = player.player_name
	ammo_label.text = str(int(player.current_weapon.weapon_stats.current_ammo.get_value()), "/", int(player.current_weapon.weapon_stats.max_ammo_capacity.get_value()))
	hp_bar.value = player.soldier_stats.HP.base_value
	hp_percentage_label.text = str(int(hp_bar.value), "%")
	move_speed_label.text = str(player.soldier_stats.speed.get_value())
	reload_time_label.text = str(player.current_weapon.weapon_stats.reload_time.get_value(), "s")
	reaction_time_label.text = str(player.soldier_stats.reaction_time.get_value(), "s")
	max_distance_label.text = str(player.soldier_stats.max_travel_distance.get_value())
	fire_rate_label.text = str(player.current_weapon.weapon_stats.fire_rate.get_value(), "rps")
	damage_label.text = str(player.current_weapon.weapon_stats.damage.get_value())
	hit_chance_label.text = str(player.current_weapon.weapon_stats.hit_chance.get_value(), "%")

func set_weapon_sprite(weapon: Weapon):
	if weapon is Pistol:
		pistol_sprite.visible = true
		m4a1_rifle_sprite.visible = false
	elif weapon is m4a1Rifle:
		m4a1_rifle_sprite.visible = true
		pistol_sprite.visible = false

func _on_deselect_player():
	hide_stats()

func _on_action_started():
	hide_stats()


func hide_stats():
	visible = false
func show_stats():
	visible = true

func _on_permanent_upgrade_applied(upgade_card: UpgradeCard):
	grid_container_applied_upgrades.add_child(upgade_card)
	update_stats_labels(PlayerSelectionManager.selected_player)

func set_applied_upgrades(player: Player):
	for child: UpgradeCard in grid_container_applied_upgrades.get_children():
		grid_container_applied_upgrades.remove_child(child)
	
	for upgrade_card_id: String in player.permanent_upgrades:
		var card: UpgradeCard = player.permanent_upgrades[upgrade_card_id]
		grid_container_applied_upgrades.add_child(card)
	
func _on_permanent_upgrade_removed(upgrade_card: UpgradeCard):
	if PlayerSelectionManager.selected_player:
		UpgradeManager.remove_permanent_perk(upgrade_card, PlayerSelectionManager.selected_player)
		update_stats_labels(PlayerSelectionManager.selected_player)

func _on_player_shoot(player: Player):
	if player == PlayerSelectionManager.selected_player:
		ammo_label.text = str(int(player.current_weapon.weapon_stats.current_ammo.get_value()), "/", int(player.current_weapon.weapon_stats.max_ammo_capacity.get_value()))

func _on_player_hit(player: Player):
	if player == PlayerSelectionManager.selected_player:
		hp_bar.value = player.soldier_stats.HP.base_value
		hp_percentage_label.text = str(int(hp_bar.value), "%")
		if hp_bar.value <= 0.0:
			hide_stats()

func _on_engagement_strategy_changed(player: Player):
	engagement_strategy_icon.texture = engagement_strategy_icons[player.current_engagement_rule]
					
