extends Node

onready var musicPlayer = get_node("Music")
onready var soundPlayer = get_node("SFX")

# var menuSongs = [
# preload("res://Assets/Audio/Music/"), 
# preload("res://Assets/Audio/Music/")
# ]

# var gameSongs = [
# preload("res://Assets/Audio/Music/"), 
# preload("res://Assets/Audio/Music/")
# ]

var menu_click = preload("res://Assets/Audio/SFX/menu_click.wav")
var collision_sound = preload("res://Assets/Audio/SFX/collision.wav")
var whoosh = preload("res://Assets/Audio/SFX/whoosh.wav")

var inGame = false

func play_music():
	if inGame:
		pass
	else:
		pass

func change_music():
	inGame = !inGame
	musicPlayer.get_node("Transition").play("Switch Music")

func play_button_click():
	soundPlayer.stream = menu_click
	soundPlayer.play()

func play_collision_sound():
	soundPlayer.stream = collision_sound
	soundPlayer.play()

func play_whoosh():
	soundPlayer.stream = whoosh
	soundPlayer.play()
