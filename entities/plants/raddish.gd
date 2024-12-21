extends Node2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent


func _ready() -> void:
	growth_cycle_component.stage_changed.connect(_on_growth_stage_changed)


func _on_growth_stage_changed(stage_idx: int):
	sprite_2d.frame = stage_idx
