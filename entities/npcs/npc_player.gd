class_name NPCPlayer
extends CharacterBody2D


#region @export vars
@export var custom_texture: Texture2D
@export var MOVE_SPEED: int = 8
# Slow down a bit when sick
@export var move_speed_sick_factor = 0.5
@export var is_idle: bool = false
@export var idle_animation: String = "idle_down"
@export var is_phone: bool = false

@export var speaker_name: String
@export var main_prompt = "You are {speaker_name}. Speak about {topic}. Speak naturally, as if you were explaining it to a friend, and avoid using overly complex words. Introduce yourself by name before discussing the topic"
@export var topics: Array[String]

@export var inventory_data: InventoryData
#endregion


#region @onready vars
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _move_dir_timer: Timer = $MoveDirTimer
@onready var _sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var _interactable_component: InteractableComponent = $InteractableComponent
@onready var _ai_dialog_component: AIDialogComponent = $AIDialogComponent
@onready var _sickness_component: SicknessComponent = $SicknessComponent
@onready var _prompt = main_prompt
#endregion


#region private vars
var _original_is_idle = false

static var _sick_prompt = "You are {speaker_name}. You are currently sick with {illness}. Explain a bit about the illness like what symptoms, how you feel, etc. Speak naturally, as if you were explaining it to a friend, and avoid using overly complex words. Introduce yourself by name before explaining the illness."
#endregion


#region built-in methods
func _ready() -> void:
	if custom_texture:
		_sprite_2d.texture = custom_texture
	else:
		print("custom_texture is not set.")
	_move_dir_timer.timeout.connect(_change_move_dir)
	_anim_player.speed_scale = 0.7
	_change_move_dir()
	
	_interactable_component.enable()
	_interactable_component.interacted.connect(_on_interactable_component_interacted)
	_interactable_component.player_in_area_changed.connect(_on_interactable_player_in_area_changed)
	_ai_dialog_component.dialog_ended.connect(_on_ai_dialog_component_dialog_ended)
	_sickness_component.got_sick.connect(_on_sickness_component_got_sick)
	_sickness_component.got_cured.connect(_on_sickness_component_got_cured)


func _physics_process(_delta: float) -> void:
	_play_anim()
	move_and_slide()
#endregion


#region public methods
func on_action_button_pressed():
	# Get the items put into the machine
	var avail_items = inventory_data.get_items()
	if avail_items.size() == 0:
		print("no items were given to npc")
		_reset_inventory_state()
		return

	var item = avail_items[0]
	
	if not Medicines.is_medicine(item):
		print("NPC cannot take non-medicine item. got item: ", item.name)
		_reset_inventory_state()
		# TODO: play error sound to notify player
		return
	
	inventory_data.consume_item(item)
	if _sickness_component.can_cure(item):
		print("medicine can cure the illness")
		_sickness_component.cure()
	else:
		print("medicine cannot cure the illness")
	
	_reset_inventory_state()
#endregion

#region private methods
func _change_move_dir():
	if is_idle:
		velocity = Vector2.ZERO
		return
	
	if randf() > 0.5:
		velocity.x = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED
		velocity.y = 0
	else:
		velocity.x = 0
		velocity.y = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED
	
	if _sickness_component.is_sick:
		velocity *= move_speed_sick_factor


func _play_anim():
	if is_phone and is_idle:
		_anim_player.play("phone")
		return
		
	if is_idle:
		_anim_player.play(idle_animation)
		return
		
	if velocity.x < 0:
		_anim_player.play("walk_left")
		_sprite_2d.flip_h = false
	elif velocity.x > 0:
		_anim_player.play("walk_left")
		_sprite_2d.flip_h = true
	elif velocity.y < 0:
		_anim_player.play("walk_up")
	elif velocity.y > 0:
		_anim_player.play("walk_down")
	else:
		_anim_player.play(idle_animation)


func _on_interactable_component_interacted():
	# Stop movement during dialog
	_original_is_idle = is_idle
	is_idle = true
	
	_change_move_dir()
	
	_ai_dialog_component.speaker_name = speaker_name
	_ai_dialog_component.main_prompt = _prompt
	_ai_dialog_component.topics = topics
	_ai_dialog_component.start_dialog()


func _on_interactable_player_in_area_changed(player_in_area: bool):
	if not player_in_area and _sickness_component.is_sick:
		_reset_inventory_state()


func _reset_inventory_state():
	Events.clear_external_inventory.emit(self)
	is_idle = _original_is_idle

func _on_ai_dialog_component_dialog_ended():
	if _sickness_component.is_sick:
		Events.toggle_external_inventory.emit(self)
	else:
		is_idle = _original_is_idle


func _on_sickness_component_got_sick(illness: String):
	_prompt = _sick_prompt.format({illness = illness})
	_sprite_2d.material.set("shader_parameter/is_sick", true)
	

func _on_sickness_component_got_cured():
	print("npc:: on cured")
	_prompt = main_prompt
	_sprite_2d.material.set("shader_parameter/is_sick", false)
	
#endregion
