extends Node2D

@export var dialogue_lines: Array[String] = []
@export var requires_password: bool = false
@export var correct_password: String = ""
@export var object_to_spawn: PackedScene

func _ready():
	$InteractArea.connect("body_entered", _on_body_entered)
	$InteractArea.connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		body.interactable = self

func _on_body_exited(body):
	if body.name == "Player":
		body.interactable = null

func interact():
	var player = get_node("/root/Main/Player")
	player.can_move = false
	var dialog_box = get_node("/root/Main/DialogueBox")

	if requires_password:
		dialog_box.request_password(correct_password, func(): player.can_move = true, self)
	else:
		if dialogue_lines.size() == 0:
			return
		dialog_box.show_dialogue(dialogue_lines, func(): player.can_move = true)
