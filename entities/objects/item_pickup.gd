class_name ItemPickup
extends Node2D

@export var slot_data: SlotData

@onready var collectible_component: CollectibleComponent = $Com
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	collectible_component.slot_data = slot_data
	texture_rect.texture = null
	if slot_data and slot_data.item_data:
		texture_rect.texture = slot_data.item_data.texture
