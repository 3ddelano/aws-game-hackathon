class_name MedicineMachine
extends StaticBody2D

@export var inventory_data: InventoryData

@onready var interactable_component: InteractableComponent = $InteractableComponent


func _ready() -> void:
	interactable_component.interacted.connect(_on_interactable_component_interacted)
	interactable_component.player_in_area_changed.connect(_on_player_in_area_changed)
	interactable_component.enable()


func _on_interactable_component_interacted():
	Events.toggle_external_inventory.emit(self)

func _on_player_in_area_changed(player_in_area: bool):
	print("player in area ", player_in_area)
	if not player_in_area:
		Events.clear_external_inventory.emit(self)
