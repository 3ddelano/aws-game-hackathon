class_name NPCPlayer
extends CharacterBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var move_dir_timer: Timer = $MoveDirTimer
@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var ai_dialog_component: AIDialogComponent = $AIDialogComponent


@export var custom_texture: Texture2D
@export var MOVE_SPEED: int = 8
@export var is_idle: bool = false
@export var idle_animation: String = "idle_down"
@export var is_phone: bool = false


@export var speaker_name: String
@export var main_prompt = "You are {speaker_name}. Speak about {topic}. Speak naturally, as if you were explaining it to a friend, and avoid using overly complex words. Introduce yourself by name before discussing the topic"
@export var topics: Array[String]

var _original_is_idle = false


func _ready() -> void:
	if custom_texture:
		sprite_2d.texture = custom_texture
	else:
		print("custom_texture is not set.")
	move_dir_timer.timeout.connect(change_move_dir)
	anim_player.speed_scale = 0.7
	change_move_dir()
	
	interactable_component.enable()
	interactable_component.interacted.connect(_on_interactable_component_interacted)
	ai_dialog_component.dialog_ended.connect(_on_ai_dialog_component_dialog_ended)


func change_move_dir():
	if is_idle:
		velocity = Vector2.ZERO
		return
	
	if randf() > 0.5:
		velocity.x = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED
		velocity.y = 0
	else:
		velocity.x = 0
		velocity.y = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED


func _play_anim():
	if is_phone and is_idle:
		anim_player.play("phone")
		return
		
	if is_idle:
		anim_player.play(idle_animation)
		return
		
	if velocity.x < 0:
		anim_player.play("walk_left")
		sprite_2d.flip_h = false
	elif velocity.x > 0:
		anim_player.play("walk_left")
		sprite_2d.flip_h = true
	elif velocity.y < 0:
		anim_player.play("walk_up")
	elif velocity.y > 0:
		anim_player.play("walk_down")
	else:
		anim_player.play(idle_animation)


func _physics_process(_delta: float) -> void:
	_play_anim()

	move_and_slide()


func _on_interactable_component_interacted():
	# Stop movement during dialog
	_original_is_idle = is_idle
	is_idle = true
	change_move_dir()
	
	ai_dialog_component.speaker_name = speaker_name
	ai_dialog_component.main_prompt = main_prompt
	ai_dialog_component.topics = topics
	ai_dialog_component.start_dialog()


func _on_ai_dialog_component_dialog_ended():
	is_idle = _original_is_idle
