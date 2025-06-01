extends CharacterBody2D

@export var speed = 400
@onready var sprite = $AnimatedSprite2D
@onready var move_sound = preload("res://Sounds/footstep.wav") # Adjust this if your file name is different

var can_move = true
var interactable = null
var interaction_cooldown = 0.0

var last_step_time := 0.0
var step_delay := 0.3 # Delay between step sounds (in seconds)

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed

	if input_direction != Vector2.ZERO:
		sprite.play("run")

		var now = Time.get_ticks_msec() / 1000.0
		if now - last_step_time > step_delay:
			last_step_time = now
			play_step_sound()

		if input_direction.x != 0:
			sprite.flip_h = input_direction.x < 0
	else:
		sprite.stop()

func play_step_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = move_sound
	sfx.volume_db = -12  # 🔊 Volume reduced to ~25% (0 dB = 100%, -12 dB = ~25%)
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

func _physics_process(_delta):
	if can_move:
		get_input()
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func _process(delta):
	if interaction_cooldown > 0:
		interaction_cooldown -= delta

	if Input.is_action_just_pressed("interact") and interactable != null and interaction_cooldown <= 0:
		sprite.play("talk")
		var dialog_box = get_node("/root/Main/DialogueBox")
		if not dialog_box.active:
			interactable.interact()

func disable_interaction_temporarily(duration = 0.2):
	interaction_cooldown = duration
