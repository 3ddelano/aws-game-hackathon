class_name MedicineMachine
extends StaticBody2D

@export var inventory_data: InventoryData

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var http_request: HTTPRequest = $HTTPRequest


func _ready() -> void:
	interactable_component.interacted.connect(_on_interactable_component_interacted)
	interactable_component.player_in_area_changed.connect(_on_player_in_area_changed)
	interactable_component.enable()


func _on_interactable_component_interacted():
	Events.toggle_external_inventory.emit(self)


func _on_player_in_area_changed(player_in_area: bool):
	if not player_in_area:
		Events.clear_external_inventory.emit(self)


func on_make_button_pressed():
	var item_counts = {}
	
	for slot_data in inventory_data.slot_datas:
		if slot_data and slot_data.item_data:
			var item = slot_data.item_data
			if item_counts.has(item):
				item_counts[item] += slot_data.item_count
			else:
				item_counts[item] = slot_data.item_count
	var items_str = ""
	for item: ItemData in item_counts:
		items_str += "- %s x%s\n" % [item.name, item_counts[item]]
		
	
	var prompt = """
You are a specialist organic medicine farmer.
You are given:
- a list of attributes and for each attribute you are given a list of items.
- a disease, its description 
- a list of available items

Your task is to evaluate whether the disease can be cured using the list of items. Provide the output with yes or no. if no then give a short, concise, one or two line explanation.

Attributes:
- antibacterial: garlic
- blood pressure-lowering: apple
- pain relief: hot pepper
- eye health: carrot
- antioxidant: cucumber, tomato
- hydrating: cucumber

Disease: High fever - A high fever can be cured using an anti bacterial.

Available Items:
%s
""" % [items_str]

	print(prompt)
	
	for item: ItemData in item_counts:
		inventory_data.consume_item(item)
	
	var output = await AIAPI.make_ai_response(prompt)
	
	print("AI Response: ", output)
	
