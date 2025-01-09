extends Control

@onready var label: Label = $Label

func _ready() -> void:
	visible = false
	Events.nearest_interactable_changed.connect(_on_nearest_interactable_changed)


func _on_nearest_interactable_changed(interactable: Area2D):
	visible = true
	if not interactable:
		visible = false
