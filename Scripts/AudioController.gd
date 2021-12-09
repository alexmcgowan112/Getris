extends Node

onready var musicPlayer = get_node("Music")
onready var soundPlayer = get_node("SFX")

var menu_song = preload("res://Assets/Audio/Music/Light-Puzzles.ogg")
var game_song = preload("res://Assets/Audio/Music/Tetris_theme.ogg")

var menu_click = preload("res://Assets/Audio/SFX/menu_click_2.wav")
var whoosh = preload("res://Assets/Audio/SFX/whoosh.wav")
var rumble = preload("res://Assets/Audio/SFX/rumble.wav")

var inGame = false

func _ready():
	if Settings.enable_music:
		play_music()

func play_music():
	if Settings.enable_music:
		if inGame:
			musicPlayer.stream = game_song
		else:
			musicPlayer.stream = menu_song
		musicPlayer.play()

func stop_music():
	musicPlayer.stop()

func change_music():
	inGame = !inGame
	if inGame:
		musicPlayer.get_node("Transition").play("Switch Music")
	else:
		musicPlayer.get_node("Transition").play_backwards("Switch Music")
	

func play_button_click():
	soundPlayer.get_node("Button Click").play()

func play_whoosh():
	soundPlayer.get_node("Whoosh").play()

func play_rumble():
	soundPlayer.get_node("Rumble").play()
