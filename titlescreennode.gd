extends Control

@onready var message_box = $MessageBox
@onready var play_button = $VBoxContainer/PlayButton
@onready var play_sound = $PlaySound  # <-- This line is new

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
		
func _on_play_button_pressed() -> void:
	play_sound.play()  # <-- Play the sound
	message_box.visible = true
	play_button.disabled = true

func _on_message_box_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://main.tscn")

func _on_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
