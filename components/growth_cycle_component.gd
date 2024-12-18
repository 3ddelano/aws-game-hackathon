class_name GrowthCycleComponent
extends Node2D

@export var num_stages: int = 4

signal stage_changed(stage_idx: int)
signal matured

var current_stage = 0
var starting_day = 0


func _ready() -> void:
	TimeManager.day_changed.connect(_on_day_changed)


func _on_day_changed(day: int):
	if starting_day == 0:
		starting_day = day

	update_stage(day)

func update_stage(day: int):
	if current_stage == num_stages - 1:
		print("already reached last stage")
		TimeManager.day_changed.disconnect(_on_day_changed)
		return

	var days_passed = day - starting_day
	current_stage = days_passed
	stage_changed.emit(current_stage)

	if current_stage == num_stages - 1:
		matured.emit()
