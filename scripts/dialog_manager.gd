extends Control

signal dialog_started
signal dialog_ended
signal dialogbox_visibility_changed(is_visible)


@export var anim_player: AnimationPlayer

@onready var dialogbox: NinePatchRect = %DialogBox
@onready var speaker_name: Label = %SpeakerName
@onready var dialog_text: Label = %DialogText
@onready var loading_text: Label = %LoadingText
@onready var next_indicator: TextureRect = %NextIndicator

const MAX_LINES = 4
const MAX_CHARS_PER_LINE = 35


# Whether a dialog is playing
var dialogbox_visible = false

var dialog_chunks = []
var current_chunk_index = 0


func show_dialogbox():
	dialogbox_visible = true
	dialogbox_visibility_changed.emit(dialogbox_visible)
	dialogbox.show()


func hide_dialogbox():
	dialogbox_visible = false
	dialogbox_visibility_changed.emit(dialogbox_visible)
	dialogbox.hide()


func show_loading_indicator():
	dialog_text.hide()
	loading_text.show()
	anim_player.play(&"loading_text")


func hide_loading_indicator():
	anim_player.stop()
	loading_text.hide()
	dialog_text.show()


func set_speaker_name(str: String):
	speaker_name.text = str


func start_dialog(text: String):
	loading_text.hide()
	next_indicator.hide()
	dialog_started.emit()
	
	dialog_chunks = _split_text_into_chunks(text, MAX_LINES * MAX_CHARS_PER_LINE)
	
	print("--- Starting dialog ---")
	print("dialog_chunks ", dialog_chunks)
	
	current_chunk_index = 0
	_show_dialog_chunk()


func _split_text_into_chunks(text: String, max_chars: int) -> Array:
	var chunks = []
	var words = text.split(" ")
	var current_chunk = ""
	var current_length = 0
	
	for word in words:
		if current_length + word.length() + 1 > max_chars:
			chunks.append(current_chunk.strip_edges())
			current_chunk = ""
			current_length = 0
		
		current_chunk += word + " "
		current_length += word.length() + 1
	
	if current_chunk.strip_edges() != "":
		chunks.append(current_chunk.strip_edges())

	return chunks


func _show_dialog_chunk():
	dialog_text.text = dialog_chunks[current_chunk_index]
	
	if current_chunk_index != dialog_chunks.size() - 1:
		next_indicator.show()
		anim_player.play(&"next_indicator")
		


func _on_next_page():
	next_indicator.hide()
	anim_player.stop()
	
	if current_chunk_index == dialog_chunks.size() - 1:
		end_dialog()
	else:
		current_chunk_index += 1
		_show_dialog_chunk()


func end_dialog():
	print("Dialog ended")
	dialog_chunks.clear()
	current_chunk_index = 0
	hide_dialogbox()
	dialog_ended.emit()


func _ready() -> void:
	dialogbox.hide()



func _on_button_pressed() -> void:
	if loading_text.visible: return
	_on_next_page()
