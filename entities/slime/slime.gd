class_name Slime
extends CharacterBody2D


@onready var move_dir_timer = $MoveDirTimer
@onready var anim_tree = $AnimationTree
@onready var health_component: HealthComponent = $HealthComponent

var move_dir = Vector2()
var speed = 35
var anim_playback: AnimationNodeStateMachinePlayback
var player: Player

func _ready():
	player = get_tree().get_first_node_in_group(&"player")
	anim_playback = anim_tree.get(&"parameters/playback")
	health_component.died.connect(func ():
		queue_free()
	)

	move_dir_timer.timeout.connect(func ():
		var dir = randi() % 4
		if dir == 0:
			move_dir = Vector2.UP
		elif dir == 1:
			move_dir = Vector2.DOWN
		elif dir == 2:
			move_dir = Vector2.LEFT
		elif dir == 3:
			move_dir = Vector2.RIGHT
	)


func _physics_process(_delta):
	handle_movement()


func handle_movement():
	if not player: return

	var dir_to_player = (player.global_position - global_position).normalized()
	if global_position.distance_squared_to(player.global_position) < 200:
		dir_to_player = Vector2()

	velocity = dir_to_player * speed

	if velocity:
		anim_tree.set(&"parameters/Idle/blend_position", dir_to_player)
		anim_tree.set(&"parameters/Walk/blend_position", dir_to_player)
		anim_playback.travel(&"Walk")
	else:
		anim_playback.travel(&"Idle")

	move_and_slide()
