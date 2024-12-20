class_name State
extends Node


var state_machine: StateMachine


func init():
	pass


func enter(_prev_state_path: String, _data = {}) -> void:
	pass


func exit() -> void:
	pass


func process_frame(_delta: float) -> void:
	pass


func process_physics(_delta: float) -> void:
	pass


func process_input(_event: InputEvent) -> void:
	pass
