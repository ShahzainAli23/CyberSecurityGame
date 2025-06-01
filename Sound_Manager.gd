extends Node

@onready var door_open_sound = preload("res://Sounds/open door.wav")

func play_door_open():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = door_open_sound
	sfx.volume_db = -10
	get_tree().get_root().add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

@onready var bgm_stream = preload("res://Sounds/bgm.mp3") # change path if needed
var bgm_player: AudioStreamPlayer = null

func play_bgm():
	if bgm_player:
		print("BGM already playing")
		return

	print("BGM starting")

	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = bgm_stream
	bgm_player.volume_db = -25  # ~30% volume
	bgm_player.bus = "Music"
	get_tree().get_root().add_child(bgm_player)
	bgm_player.play()

	# ✅ Manual loop workaround for MP3 streams
	bgm_player.finished.connect(func(): bgm_player.play())
