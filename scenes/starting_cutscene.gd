extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var skip_label: Label = $CanvasLayer/SkipLabel
@onready var scenes: Control = $CanvasLayer/Scenes
@onready var scene1: TextureRect = $CanvasLayer/Scenes/Scene1
@onready var scene_extra: TextureRect = $CanvasLayer/Scenes/SceneExtra
@onready var scene_extra1: TextureRect = $CanvasLayer/Scenes/SceneExtra1
@onready var scene2: TextureRect = $CanvasLayer/Scenes/Scene2
@onready var scene3: TextureRect = $CanvasLayer/Scenes/Scene3
@onready var scene4: TextureRect = $CanvasLayer/Scenes/Scene4
@onready var scene1_audio: AudioStreamPlayer2D = $Scene1Audio
@onready var scene2_audio: AudioStreamPlayer2D = $Scene2Audio
@onready var scene3_audio: AudioStreamPlayer2D = $Scene3Audio
@onready var scene4_audio: AudioStreamPlayer2D = $Scene4Audio
@onready var bg_audio: AudioStreamPlayer2D = $BgAudio
@onready var _scenes = [scene1, scene2, scene3, scene4]
@onready var _audios = [scene1_audio, scene2_audio, scene3_audio, scene4_audio]


var _current_index = 0
## If we left click twice it skips cutscene
var _skip_pressed_count = 0


func _ready():
	show()
	canvas_layer.show()
	_reset_scenes()
	_start_cutscene()


func _reset_scenes():
	for child in scenes.get_children():
		child.hide()


func _start_cutscene():
	var scene = _scenes[_current_index]
	var audio = _audios[_current_index]
	
	SceneManager.end_transition()
	scene.show()
	audio.play()
	
	await audio.finished
	
	SceneManager.start_transtition()
	
	if _current_index < _scenes.size() - 1:
		_current_index += 1
		_reset_scenes()
		_start_cutscene()
	else:
		_on_end()


func _on_end():
	for audio: AudioStreamPlayer2D in _audios:
		audio.stop()
		
	hide()
	canvas_layer.hide()
	SceneManager.end_transition()
	bg_audio.play()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_skip_pressed_count += 1
		
		skip_label.show()
		
		if _skip_pressed_count == 2 and visible:
			_on_end()
