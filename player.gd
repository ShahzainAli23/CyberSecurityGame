extends CharacterBody2D

@export var speed = 400
@onready var sprite = $AnimatedSprite2D

var can_move = true
var interactable = null
var interaction_cooldown = 0.0

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	
	if input_direction != Vector2.ZERO:
		sprite.play("run")
		
		if input_direction.x != 0:
			sprite.flip_h = input_direction.x < 0  # flip left if moving left
	else:
		sprite.stop()

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
