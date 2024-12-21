extends Node2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var drop_item_component: DropItemComponent = $DropItemComponent
@onready var drop_marker: Marker2D = $DropMarker
@onready var interactable_component: InteractableComponent = $InteractableComponent


func _ready() -> void:
	growth_cycle_component.stage_changed.connect(_on_growth_stage_changed)
	interactable_component.interacted.connect(_on_interactable_component_interacted)


func _on_growth_stage_changed(stage_idx: int):
	sprite_2d.frame = stage_idx


func _on_interactable_component_interacted() -> void:
	if growth_cycle_component.is_matured():
		growth_cycle_component.reset()
		drop_item_component.drop_at_position(get_parent(), drop_marker.global_position)
