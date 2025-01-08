class_name AIDialogComponent
extends Node2D

signal dialog_ended

@export var speaker_name: String
@export var main_prompt = "You are {speaker_name}. Speak about {topic}. Speak naturally, as if you were explaining it to a friend, and avoid using overly complex words. Introduce yourself by name before discussing the topic"
@export var topics: Array[String]



func start_dialog():
	DialogManager.dialog_ended.connect(func ():
		dialog_ended.emit()
	, CONNECT_ONE_SHOT)
	
	var prompt = main_prompt.format({"speaker_name" = speaker_name})
	if topics.size() > 0:
		var topic = topics.pick_random()
		prompt = prompt.format({"topic" = topic})
	
	
	print("Dialog started: speaker_name=%s, prompt=%s" % [speaker_name, prompt])
	
	DialogManager.show_dialogbox()
	DialogManager.set_speaker_name(speaker_name)
	DialogManager.show_loading_indicator()
	
	var text = await AIAPI.make_ai_response(prompt)
	DialogManager.hide_loading_indicator()
	
	DialogManager.start_dialog(text)
