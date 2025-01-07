class_name InventoryManager
extends Control

@export var player: Player
@export var player_inventory: Inventory
@export var external_inventory: Inventory
@onready var external_inventory_container: VBoxContainer = $ExternalInventoryContainer

@onready var grabbed_slot: Slot = $GrabbedSlot


var grabbed_slot_data: SlotData = null
var external_inventory_owner: Node = null


func _ready() -> void:
	player.inventory_data.inventory_slot_clicked.connect(_on_inventory_slot_clicked)
	Events.player_inventory_visibility_changed.connect(_on_player_inventory_visibility_changed)
	
	player_inventory.set_inventory_data(player.inventory_data)
	
	Events.toggle_external_inventory.connect(_on_toggle_external_inventory)
	Events.clear_external_inventory.connect(_on_clear_external_inventory)


func _process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position()


func _on_player_inventory_visibility_changed(is_visible: bool):
	player_inventory.visible = is_visible


func _on_toggle_external_inventory(inv_owner: Node):
	if external_inventory_owner == inv_owner:
		clear_external_inventory()
	else:
		set_external_inventory(inv_owner)


func _on_clear_external_inventory(inv_owner: Node):
	if external_inventory_owner == inv_owner:
		clear_external_inventory()
	

func set_external_inventory(inv_owner: Node):
	external_inventory_owner = inv_owner
	
	var inv_data = inv_owner.inventory_data
	inv_data.inventory_slot_clicked.connect(_on_inventory_slot_clicked)
	external_inventory.set_inventory_data(inv_data)
	external_inventory_container.show()


func clear_external_inventory():
	if external_inventory_owner:
		var inv_data = external_inventory_owner.inventory_data
		inv_data.inventory_slot_clicked.disconnect(_on_inventory_slot_clicked)
		external_inventory.clear_inventory_data(inv_data)

	external_inventory_owner = null
	external_inventory_container.hide()


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
