class_name InventoryData
extends Resource

@export var slot_datas: Array[SlotData]


signal inventory_updated(inventory_data: InventoryData)
signal inventory_slot_clicked(inventory_data: InventoryData, slot_index: int, button_index: int)


## Returns true if successfully picked up
func pick_up_slot_data(to_pick_up_slot_data: SlotData) -> bool:
	# Try to merge in existing
	for slot_data in slot_datas:
		if slot_data.can_fully_merge_with(to_pick_up_slot_data):
			slot_data.fully_merge_with(to_pick_up_slot_data)
			inventory_updated.emit(self)
			return true
	
	# Try to find empty slot
	var empty_slot_index = _find_empty_slot_index()
	if empty_slot_index == null:
		push_error("Cannot add item=%s, count=%s, reason: inventory is full" % [to_pick_up_slot_data.item_data.name, to_pick_up_slot_data.item_count])
		return false
	
	slot_datas[empty_slot_index] = SlotData.new()
	slot_datas[empty_slot_index].item_data = to_pick_up_slot_data.item_data
	slot_datas[empty_slot_index].item_count = 1
	inventory_updated.emit(self)
	
	return true


func on_slot_clicked(slot_index: int, button_index: int):
	inventory_slot_clicked.emit(self, slot_index, button_index)


func _find_empty_slot_index():
	for i in range(len(slot_datas)):
		var slot_data = slot_datas[i]
		if not slot_data or not slot_data.item_data:
			return i
	return null


func grab_slot_data(slot_index: int) -> SlotData:
	var slot_data = slot_datas[slot_index]
	
	if slot_data:
		slot_datas[slot_index] = null
		inventory_updated.emit(self)
	
	return slot_data


func drop_slot_data(grabbed_slot_data: SlotData, slot_index: int) -> SlotData:
	var slot_data = slot_datas[slot_index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[slot_index] = grabbed_slot_data
		return_slot_data = slot_data
		
	inventory_updated.emit(self)
	
	return return_slot_data


func drop_single_slot_data(grabbed_slot_data: SlotData, slot_index: int) -> SlotData:
	var slot_data = slot_datas[slot_index]
	
	if not slot_data or not slot_data.item_data:
		slot_datas[slot_index] = grabbed_slot_data.decrease_single_item_count()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.decrease_single_item_count())
		
	inventory_updated.emit(self)
	
	if grabbed_slot_data.item_count > 0:
		return grabbed_slot_data

	return null
