class_name Player
extends CharacterBody2D

@export var move_speed = 100.0
@export var bullet_scene: PackedScene

@export var anim_tree: AnimationTree
@export var shoot_cooldown_timer: Timer
@export var inventory_data: InventoryData


@onready var facing_direction: Marker2D = $FacingDirection
@onready var interactable_finder: Area2D = $FacingDirection/InteractableFinder


var anim_playback: AnimationNodeStateMachinePlayback
var nearest_interactable: Area2D = null


func _ready():
	anim_playback = anim_tree.get(&"parameters/playback")


func _process(_delta):
	if Input.is_action_pressed(&"shoot"):
		handle_shoot()
	check_nearest_interactable()


func _physics_process(_delta):
	handle_movement()


func handle_movement():
	var input_vector = Vector2()
	if Input.is_action_pressed(&"move_right"):
		input_vector.x = 1
		facing_direction.rotation_degrees = 90
	elif Input.is_action_pressed(&"move_left"):
		input_vector.x = -1
		facing_direction.rotation_degrees = 270
	elif Input.is_action_pressed(&"move_up"):
		input_vector.y = -1
		facing_direction.rotation_degrees = 0
	elif Input.is_action_pressed(&"move_down"):
		input_vector.y = 1
		facing_direction.rotation_degrees = 180
	velocity = input_vector * move_speed
	move_and_slide()

	if velocity:
		anim_tree.set(&"parameters/Idle/blend_position", input_vector)
		anim_tree.set(&"parameters/Walk/blend_position", input_vector)
		anim_playback.travel(&"Walk")
	else:
		anim_playback.travel(&"Idle")


func handle_shoot():
	if Events.is_player_inventory_visible: return
	if not shoot_cooldown_timer.is_stopped():
		return
	var bullet = bullet_scene.instantiate()
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	bullet.position = global_position + direction * 5
	bullet.shoot(direction, 180.0)
	get_tree().get_current_scene().add_child(bullet)

	shoot_cooldown_timer.start()


func check_nearest_interactable():
	var shortest_dist = INF
	var next_nearest_interactable = null

	for area in interactable_finder.get_overlapping_areas():
		var dist = area.global_position.distance_squared_to(global_position)
		if dist < shortest_dist:
			shortest_dist = dist
			next_nearest_interactable = area
	
	if nearest_interactable != next_nearest_interactable:
		nearest_interactable = next_nearest_interactable
		Events.nearest_interactable_changed.emit(nearest_interactable)


func _unhandled_input(event: InputEvent) -> void:
	if nearest_interactable and Input.is_action_just_pressed(&"interact"):
		nearest_interactable.interact()
		get_viewport().set_input_as_handled()

	if Input.is_action_just_pressed(&"toggle_inventory"):
		Events.toggle_player_inventory()
