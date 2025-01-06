class_name DropItemComponent
extends Node2D

@export var item_data: ItemData

const ItemPickupScene = preload("res://entities/objects/item_pickup.tscn")

func drop_at_position(parent: Node, drop_pos: Vector2) -> void:
	var obj = ItemPickupScene.instantiate()
	obj.global_position = drop_pos
	obj.slot_data = SlotData.from_item_data(item_data)
	parent.add_child(obj)
