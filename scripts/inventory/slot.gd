class_name Slot
extends PanelContainer

signal slot_clicked(slot_index: int, button_index: int)

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

const TooltipScene = preload("res://scripts/inventory/tooltip.tscn")

func set_slot_data(slot_data: SlotData):
	texture_rect.texture = null
	quantity_label.visible = false
	
	if not slot_data: return
	
	if slot_data.item_data:
		texture_rect.texture = slot_data.item_data.texture
		tooltip_text = "%s\n%s" % [slot_data.item_data.name, slot_data.item_data.description]
	
	if slot_data.item_count > 1:
		quantity_label.visible = true
		quantity_label.text = "x%s" % slot_data.item_count


func _make_custom_tooltip(for_text: String) -> Object:
	var custom_tooltip = TooltipScene.instantiate()
	custom_tooltip.text = for_text
	return custom_tooltip


func _on_gui_input(_event: InputEvent) -> void:
	if not _event is InputEventMouseButton: return
	
	var event = _event as InputEventMouseButton
	
	if event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or \
		 event.button_index == MOUSE_BUTTON_RIGHT):
		slot_clicked.emit(get_index(), event.button_index)
		get_viewport().set_input_as_handled()
