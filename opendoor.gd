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
	queue_free()
