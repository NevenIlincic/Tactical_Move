extends Node2D
class_name UpgradeMenu

var alive_players: Dictionary = {} 
@onready var grid_container_available: GridContainer = $Grid_Container_Available
@onready var confirmation_dialog: ConfirmDialog = $ConfirmationDialog

var current_confirm_callback: Callable

func set_alive_players(players: Dictionary):
	alive_players = players

func _ready() -> void:
	PlayerSelectionManager.player_selection_changed.connect(_on_changed_selected_player)
	Signals.open_upgrade_confirmation_dialog.connect(_on_confirmation_dialog_opened)
	confirmation_dialog.action_confirmed.connect(_on_action_confirmed)
	confirmation_dialog.action_canceled.connect(_on_action_canceled)
func show_upgrade_menu():
	visible = true
	for upgrade_card_id: String in UpgradeCardsManager.available_permanent_upgrades:
		var card: UpgradeCard = UpgradeCardsManager.available_permanent_upgrades[upgrade_card_id]
		if card.get_parent() == null:
			grid_container_available.add_child(card)
	
	#fill_applied_upgrades_grid()
func hide_upgrade_menu():
	visible = false

func _on_changed_selected_player(_old_player: Player, _new_player: Player):
	#clear_grid(grid_container_applied)
	#fill_applied_upgrades_grid()
	pass

func clear_grid(grid_container: GridContainer):
	for child in grid_container.get_children():
		grid_container.remove_child(child)

func remove_card_from_grid(grid_container: GridContainer, upgrade_card: UpgradeCard):
	for child in grid_container.get_children():
		if child.unique_id == upgrade_card.unique_id:
			grid_container.remove_child(child)
			break

#func fill_applied_upgrades_grid():
	#if PlayerSelectionManager.selected_player:
		#for upgrade_card_id: String in PlayerSelectionManager.selected_player.permanent_upgrades:
			#var card: UpgradeCard = PlayerSelectionManager.selected_player.permanent_upgrades[upgrade_card_id]
			#grid_container_applied.add_child(card)

func _on_confirmation_dialog_opened(upgrade_card: UpgradeCard):
	var dialog_text: String = "Are you sure you want to apply this upgrade?"
	confirmation_dialog.set_dialog_label_text(dialog_text)
	confirmation_dialog.visible = true
	
	current_confirm_callback = func():
		for child in grid_container_available.get_children():
			if child.unique_id == upgrade_card.unique_id:
				grid_container_available.remove_child(child)
				break
		upgrade_card.is_applied = true
		UpgradeManager.apply_permanent_perk(upgrade_card, PlayerSelectionManager.selected_player)
		Signals.permanent_upgrade_applied.emit(upgrade_card)
	#remove_card_from_grid(grid_container_available, upgrade_card)

func _on_action_confirmed():
	if current_confirm_callback.is_valid():
		current_confirm_callback.call()
		current_confirm_callback = Callable()
	confirmation_dialog.visible = false
func _on_action_canceled():
	current_confirm_callback = Callable()
	confirmation_dialog.visible = false
