extends Node2D

@export var dialogue_lines: Array[String] = []
@export var requires_password: bool = false
@export var correct_password: String = ""
@export var object_to_spawn: PackedScene
@export var post_password_dialogue: Array[String] = []


func _ready():
	$InteractArea.connect("body_entered", _on_body_entered)
	$InteractArea.connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		body.interactable = self

func _on_body_exited(body):
	if body.name == "Player":
		body.interactable = null
		

func _go_to_title_screen():
	get_tree().change_scene_to_file("res://titlescreen.tscn")

func interact():
	var player = get_node("/root/Main/Player")
	player.can_move = false
	var dialog_box = get_node("/root/Main/DialogueBox")

	if requires_password:
		# DO NOT pass a lambda that captures `self`
		dialog_box.request_password(correct_password, "ItemPostPassword", self)
	else:
		if dialogue_lines.size() == 0:
			return
		dialog_box.show_dialogue(dialogue_lines, func():
			player.can_move = true)
			
func ItemPostPassword():
	var dialog_box = get_node("/root/Main/DialogueBox")
	if post_password_dialogue.size() > 0:
		dialog_box.show_dialogue(post_password_dialogue, func():
			get_tree().quit()
		)
	else:
		get_tree().quit()
