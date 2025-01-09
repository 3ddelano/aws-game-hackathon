class_name Player
extends CharacterBody2D

@export var move_speed = 100.0
@export var bullet_scene: PackedScene

@export var anim_tree: AnimationTree
@export var shoot_cooldown_timer: Timer
@export var inventory_data: InventoryData

@onready var interactable_finder: Area2D = $InteractableFinder
@onready var right_area: CollisionShape2D = $InteractableFinder/RightArea
@onready var up_area: CollisionShape2D = $InteractableFinder/UpArea
@onready var down_area: CollisionShape2D = $InteractableFinder/DownArea
@onready var left_area: CollisionShape2D = $InteractableFinder/LeftArea


var anim_playback: AnimationNodeStateMachinePlayback
var nearest_interactable: Area2D = null

var can_move = true
var can_shoot = true


func _ready():
	anim_playback = anim_tree.get(&"parameters/playback")
	DialogManager.dialogbox_visibility_changed.connect(_on_dialogmanager_dialogbox_visibility_changed)
	
	interactable_finder.area_entered.connect(_on_interactable_finder_area_entered)
	interactable_finder.area_exited.connect(_on_interactable_finder_area_exited)


func _process(_delta):
	if Input.is_action_pressed(&"shoot"):
		_handle_shoot()
	_check_nearest_interactable()


func _physics_process(_delta):
	_handle_movement()
	_update_interactable_finder_collisions()


func _update_interactable_finder_collisions():
	if velocity != Vector2.ZERO:
		right_area.disabled = true
		up_area.disabled = true
		down_area.disabled = true
		left_area.disabled = true
	
	if velocity.x > 0:
		right_area.disabled = false
	elif velocity.x < 0:
		left_area.disabled = false
	elif velocity.y > 0:
		down_area.disabled = false
	elif velocity.y < 0:
		up_area.disabled = false


func _handle_movement():
	if not can_move: return
		
	var input_vector = Vector2()
	if Input.is_action_pressed(&"move_right"):
		input_vector.x = 1
	elif Input.is_action_pressed(&"move_left"):
		input_vector.x = -1
	elif Input.is_action_pressed(&"move_up"):
		input_vector.y = -1
	elif Input.is_action_pressed(&"move_down"):
		input_vector.y = 1
	
	velocity = input_vector * move_speed
	move_and_slide()

	if velocity:
		anim_tree.set(&"parameters/Idle/blend_position", input_vector)
		anim_tree.set(&"parameters/Walk/blend_position", input_vector)
		anim_playback.travel(&"Walk")
	else:
		anim_playback.travel(&"Idle")


func _handle_shoot():
	if not can_shoot: return
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


func _check_nearest_interactable():
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


func _on_dialogmanager_dialogbox_visibility_changed(dialogbox_visible: bool):
	if dialogbox_visible:
		can_move = false
		can_shoot = false
	else:
		can_move = true
		can_shoot = true


func _on_interactable_finder_area_entered(area):
	if area is InteractableComponent:
		area.player_in_area = true
		area.player_in_area_changed.emit(true)


func _on_interactable_finder_area_exited(area):
	if area is InteractableComponent:
		area.player_in_area = false
		area.player_in_area_changed.emit(false)
