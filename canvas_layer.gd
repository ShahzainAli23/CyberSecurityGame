extends CanvasLayer

@onready var label = $Panel/Label
@onready var next_icon = $Panel/NextIcon

var dialogue_lines = []
var current_index = 0
var active = false
var finished_callback = null

var password_fail_line: String = "\n \nWrong password!"

var mode: String = "dialogue"
var input_buffer: String = ""
var expected_password: String = ""

var typing = false
var type_speed = 0.03
var full_text = ""
var char_index = 0
var stop_typing = false

func _ready():
	visible = false
	next_icon.visible = false

func show_dialogue(lines: Array, callback = null):
	dialogue_lines = lines
	current_index = 0
	finished_callback = callback
	active = true
	visible = true
	mode = "dialogue"
	show_line(dialogue_lines[current_index])

func show_line(text: String):
	stop_typing = false
	label.text = ""
	full_text = text
	char_index = 0
	typing = true
	next_icon.visible = false
	type_next_character()

func type_next_character():
	if stop_typing:
		return

	if char_index < full_text.length():
		label.text += full_text[char_index]
		char_index += 1
		await get_tree().create_timer(type_speed).timeout
		type_next_character()
	else:
		typing = false
		next_icon.visible = true

func request_password(correct_password: String, callback = null):
	expected_password = correct_password
	input_buffer = ""
	mode = "input"
	finished_callback = callback
	active = true
	visible = true
	label.text = "Enter the password:\n> "
	next_icon.visible = false

func _input(event):
	if not active:
		return

	if mode == "dialogue":
		if event.is_action_pressed("cycle_through_dialogues"):
			if typing:
				stop_typing = true
				label.text = full_text
				typing = false
				next_icon.visible = true
			else:
				current_index += 1
				if current_index >= dialogue_lines.size():
					_close()
				else:
					show_line(dialogue_lines[current_index])

	elif mode == "input":
		if event is InputEventKey and event.pressed:
			var key := String.chr(event.unicode)
			if key.length() > 0 and key != "\n":
				input_buffer += key
			elif event.keycode == KEY_BACKSPACE and input_buffer.length() > 0:
				input_buffer = input_buffer.substr(0, input_buffer.length() - 1)
			elif event.keycode == KEY_ENTER or event.is_action_pressed("cycle_through_dialogues"):
				if input_buffer == expected_password:
					print("Access granted!")
					_close()
				else:
					label.text = "\n"
					show_dialogue([password_fail_line], func():
						var player = get_node("/root/Main/Player")
						player.can_move = true
					)

			label.text = "Enter the password:\n> " + input_buffer

func _close():
	active = false
	visible = false
	mode = "dialogue"

	var player = get_node("/root/Main/Player")
	player.disable_interaction_temporarily()

	if finished_callback:
		call_deferred("_run_callback", finished_callback)


func _run_callback(cb: Callable):
	cb.call()
