class_name SlotData
extends Resource

const MAX_STACK_SIZE = 99

@export var item_data: ItemData
@export_range(1, MAX_STACK_SIZE) var item_count = 1: set = set_item_count


func set_item_count(new_count: int):
	item_count = new_count
	
	if item_count > 1 and not item_data.stackable:
		item_count = 1
		push_error("%s is not stackable" % item_data.name)

func can_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data and \
		item_data.stackable and \
		item_count < MAX_STACK_SIZE


func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data and \
		item_data.stackable and \
		item_count + other_slot_data.item_count <= MAX_STACK_SIZE


func fully_merge_with(other_slot_data: SlotData):
	item_count += other_slot_data.item_count


func decrease_single_item_count():
	var slot_data = duplicate()
	slot_data.item_count = 1
	item_count -= 1
	return slot_data
