extends Node2D


#region Signals
#endregion


#region enums/constants
#endregion


#region @export vars
#endregion


#region public vars
#endregion


#region private vars
#endregion


#region @onready vars
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
#endregion


#region built-in methods
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass
#endregion


#region public methods
func transition_to_position(node: Node2D, global_pos: Vector2):
	await start_transtition()
	node.global_position = global_pos
	await end_transition()


func start_transtition():
	_animation_player.play(&"slide_in")
	await _animation_player.animation_finished


func end_transition():
	_animation_player.play(&"slide_out")
	await _animation_player.animation_finished
#endregion


#region private methods
#endregion
