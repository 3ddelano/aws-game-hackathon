class_name CollectibleComponent
extends Area2D

signal collected(item_data: SlotData)


@export var slot_data: SlotData
@export var queue_free_on_collected = true


func _ready() -> void:
	monitoring = false
	await get_tree().create_timer(0.2).timeout
	monitoring = true


func _on_body_entered(body: Node2D) -> void:
	if not slot_data:
		push_error("slot_data is required.")

	if body is Player and body.inventory_data.pick_up_slot_data(slot_data):
		print(&"Collected item=%s, count=%s" % [slot_data.item_data.name, slot_data.item_count])
		collected.emit(slot_data)
		if queue_free_on_collected:
			get_parent().queue_free()
