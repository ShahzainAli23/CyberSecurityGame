extends Node2D

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

	var final_dialogue = [
		"It shows all the critical information on the screen",
		"You’ve successfully found agent 01's location",
		"Game over. Thank you for playing."
	]

	dialog_box.show_dialogue(final_dialogue, func():
		get_tree().quit()
	)
