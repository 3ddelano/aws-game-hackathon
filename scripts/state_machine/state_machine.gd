class_name StateMachine
extends Node


@export
var initial_state: State = null


@onready
var current_state: State = initial_state if initial_state != null else get_child(0)


func _ready() -> void:
	await owner.ready

	if get_child_count() == 0:
		printerr("(%s) StateMachine:_ready No states found" % [owner.name])
		return

	for child: State in get_children():
		child.state_machine = self
		child.init()

	current_state.enter(&"")


func change_state(new_state_path: String) -> void:
	if not has_node(new_state_path):
		printerr("(%s) StateMachine:change_state No node with path %s was found" % [owner.name, new_state_path])
		return

	current_state.exit()
	var prev_state_path = current_state.name
	current_state = get_node(new_state_path)
	current_state.enter(prev_state_path)


func _process(delta: float) -> void:
	current_state.process_frame(delta)

func _physics_process(delta: float) -> void:
	current_state.process_physics(delta)


func _unhandled_input(event: InputEvent) -> void:
	current_state.process_input(event)
