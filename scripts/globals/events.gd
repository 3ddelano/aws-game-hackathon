extends Node

var is_player_inventory_visible = false

signal nearest_interactable_changed(interactable: Area2D)
signal player_inventory_visibility_changed(is_visible: bool)
signal toggle_external_inventory(inventory_owner)
signal clear_external_inventory(inventory_owner, value)


func toggle_player_inventory():
	is_player_inventory_visible = not is_player_inventory_visible
	player_inventory_visibility_changed.emit(is_player_inventory_visible)
