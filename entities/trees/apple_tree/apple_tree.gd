extends StaticBody2D

@export var apple_scene: PackedScene

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var drop_marker: Marker2D = $DropMarker


func _ready() -> void:
	growth_cycle_component.starting_time += randf_range(30, 60) * TimeManager.GAME_MINUTE_DURATION


func _on_interactable_component_interacted() -> void:
	if growth_cycle_component.is_matured():
		growth_cycle_component.reset()

		var apple = apple_scene.instantiate()
		apple.global_position = drop_marker.global_position
		get_parent().add_child(apple)


func _on_growth_cycle_component_stage_changed(stage_idx: int) -> void:
	if stage_idx == 0:
		animated_sprite_2d.play(&"notripe")
	else:
		animated_sprite_2d.play(&"ripe")
