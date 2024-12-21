extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var drop_marker: Marker2D = $DropMarker
@onready var drop_item_component: DropItemComponent = $DropItemComponent
@onready var interactable_component: InteractableComponent = $InteractableComponent


func _ready() -> void:
	growth_cycle_component.starting_time += randf_range(30, 60) * TimeManager.GAME_MINUTE_DURATION
	interactable_component.interacted.connect(_on_interactable_component_interacted)
	growth_cycle_component.stage_changed.connect(_on_growth_cycle_component_stage_changed)


func _on_interactable_component_interacted() -> void:
	if growth_cycle_component.is_matured():
		growth_cycle_component.reset()

		drop_item_component.drop_at_position(get_parent(), drop_marker.global_position)


func _on_growth_cycle_component_stage_changed(stage_idx: int) -> void:
	if stage_idx == 0:
		animated_sprite_2d.play(&"notripe")
	else:
		animated_sprite_2d.play(&"ripe")
