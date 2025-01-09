class_name TeleporterComponent
extends Node2D


#region Signals
#endregion


#region enums/constants
#endregion


#region @export vars
@export var to_marker: Marker2D
@export var play_transition = true
#endregion


#region public vars
#endregion


#region private vars
#endregion


#region @onready vars
@onready var interactable_component: InteractableComponent = $InteractableComponent
#endregion


#region built-in methods
func _ready() -> void:
	interactable_component.enable()
	interactable_component.interacted.connect(_on_interactable_component_interacted)


func _process(delta: float) -> void:
	pass
#endregion


#region public methods
#endregion


#region private methods
func _on_interactable_component_interacted():
	var player = get_tree().get_first_node_in_group(&"player")
	SceneManager.transition_to_position(player, to_marker.global_position)
#endregion


