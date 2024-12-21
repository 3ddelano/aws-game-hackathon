extends CharacterBody2D

@export var egg_scene: PackedScene

@onready var drop_marker: Marker2D = $DropMarker


func _on_interactable_component_interacted() -> void:
	var egg = egg_scene.instantiate()
	egg.global_position = drop_marker.global_position
	get_parent().add_child(egg)
