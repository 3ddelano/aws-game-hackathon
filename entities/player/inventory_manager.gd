class_name InventoryManager
extends Control

@export var player: Player
@export var player_inventory: Inventory

@onready var grabbed_slot: Slot = $GrabbedSlot


var grabbed_slot_data: SlotData = null


func _ready() -> void:
	player.inventory_data.inventory_slot_clicked.connect(_on_inventory_slot_clicked)
	Events.player_inventory_visibility_changed.connect(_on_player_inventory_visibility_changed)
	
	player_inventory.set_inventory_data(player.inventory_data)


func _process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position()


func _on_player_inventory_visibility_changed(is_visible: bool):
	player_inventory.visible = is_visible
	

func _on_inventory_slot_clicked(inv_data: InventoryData, slot_index: int, button_index: int):
	match [grabbed_slot_data, button_index]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inv_data.grab_slot_data(slot_index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inv_data.drop_slot_data(grabbed_slot_data, slot_index)
			
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inv_data.drop_single_slot_data(grabbed_slot_data, slot_index)
	
	update_grabbed_slot()


func update_grabbed_slot():
	grabbed_slot.visible = !!grabbed_slot_data
	grabbed_slot.set_slot_data(grabbed_slot_data)
