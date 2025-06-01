extends CanvasLayer

@onready var label = $Panel/Label
@onready var next_icon = $Panel/NextIcon

# 🔊 Sound files
@onready var dialogue_beep = preload("res://Sounds/Dialogue.wav")
@onready var password_correct = preload("res://Sounds/success.wav")
@onready var password_wrong = preload("res://Sounds/fail.mp3")

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
var item_to_destroy: Node = null

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
	play_sound(dialogue_beep, -25) # 🔊 10% volume
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

func request_password(correct_password: String, callback = null, item: Node = null):
	expected_password = correct_password
	input_buffer = ""
	mode = "input"
	finished_callback = callback
	active = true
	visible = true
	label.text = "Enter the password:\n> "
	next_icon.visible = false
	item_to_destroy = item

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
					play_sound(password_correct, -6) # ✅ 50% volume
					if is_instance_valid(item_to_destroy):
						var position = item_to_destroy.position
						var parent = item_to_destroy.get_parent()
						var replacement_scene = item_to_destroy.object_to_spawn if "object_to_spawn" in item_to_destroy else null

						item_to_destroy.queue_free()

						if replacement_scene:
							var new_instance = replacement_scene.instantiate()
							new_instance.position = position
							parent.add_child(new_instance)

					_close()
				else:
					play_sound(password_wrong, -6) # ❌ 50% volume
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

func _run_callback(cb):
	if cb == null:
		return

	if typeof(cb) == TYPE_STRING:
		if is_instance_valid(item_to_destroy) and item_to_destroy.has_method(cb):
			item_to_destroy.call(cb)

	elif typeof(cb) == TYPE_CALLABLE and cb.is_valid():
		cb.call()

# 🔊 Sound helper with custom volume
func play_sound(stream: AudioStream, volume_db := -12):
	var sfx = AudioStreamPlayer.new()
	sfx.stream = stream
	sfx.volume_db = volume_db
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)
