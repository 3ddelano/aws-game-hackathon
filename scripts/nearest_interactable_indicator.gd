extends Control

@onready var label: Label = $Label

func _ready() -> void:
	label.visible = false
	
	Events.nearest_interactable_changed.connect(_on_nearest_interactable_changed)


func _on_nearest_interactable_changed(interactable: Area2D):
	if interactable == null:
		label.visible = false
		return
	
	label.visible = true
