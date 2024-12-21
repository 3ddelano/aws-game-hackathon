class_name GrowthCycleComponent
extends Node2D

@export var num_stages: int = 4

signal stage_changed(stage_idx: int)
signal matured

var current_stage = 0
var starting_time = 0


func _ready() -> void:
	TimeManager.time_updated.connect(_on_time_manager_time_updated)
	starting_time = TimeManager.time

	await owner.ready
	stage_changed.emit(0)


func _on_time_manager_time_updated(_day: int, _hour: int, _minute: int):
	var days = TimeManager.to_days(TimeManager.time - starting_time)
	update_stage(days)


func update_stage(day: int):
	if current_stage == num_stages - 1:
		return

	var days_passed = day
	if current_stage != days_passed:
		current_stage = days_passed
		stage_changed.emit(current_stage)

	if current_stage == num_stages - 1:
		matured.emit()


func reset():
	current_stage = 0
	starting_time = TimeManager.time
	stage_changed.emit(current_stage)


func is_matured() -> bool:
	return current_stage == num_stages - 1
