extends CharacterBody2D

@onready var drop_marker: Marker2D = $DropMarker
@onready var drop_item_component: DropItemComponent = $DropItemComponent
@onready var interactable_component: InteractableComponent = $InteractableComponent


func _ready() -> void:
	interactable_component.interacted.connect(_on_interactable_component_interacted)
	interactable_component.enable()


func _on_interactable_component_interacted() -> void:
	drop_item_component.drop_at_position(get_parent(), drop_marker.global_position)
