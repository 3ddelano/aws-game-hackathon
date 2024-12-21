extends CharacterBody2D

@export var milk_scene: PackedScene

@onready var drop_marker: Marker2D = $DropMarker


func _on_interactable_component_interacted() -> void:
	var milk = milk_scene.instantiate()
	milk.global_position = drop_marker.global_position
	get_parent().add_child(milk)
