extends Node2D

@export var growth_frame_ids: Array[int]
@export var use_sprites_list = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var drop_item_component: DropItemComponent = $DropItemComponent
@onready var drop_marker: Marker2D = $DropMarker
@onready var interactable_component: InteractableComponent = $InteractableComponent


func _ready() -> void:
	growth_cycle_component.stage_changed.connect(_on_growth_stage_changed)
	growth_cycle_component.matured.connect(_on_growth_matured)
	interactable_component.interacted.connect(_on_interactable_component_interacted)


func _on_growth_stage_changed(stage_idx: int):
	if use_sprites_list:
		var sprites = get_node("Sprites")
		for c in sprites.get_children():
			c.hide()
		sprites.get_child(stage_idx).show()
		return
	
	
	if len(growth_frame_ids) > 0:
		sprite_2d.frame = growth_frame_ids[stage_idx]
	else:
		sprite_2d.frame = stage_idx


func _on_interactable_component_interacted() -> void:
	if growth_cycle_component.is_matured():
		growth_cycle_component.reset()
		interactable_component.disable()
		drop_item_component.drop_at_position(get_parent(), drop_marker.global_position)


func _on_growth_matured():
	interactable_component.enable()
