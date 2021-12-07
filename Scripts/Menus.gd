#TODO - SFX

extends Node


onready var currentScene = $MainMenu

func _ready():
	register_buttons()
	change_screen(currentScene)

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("Buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button])
		
		match button.name:
			"Music":
				button.pressed = !Settings.enable_music
			"Sound":
				button.pressed = !Settings.enable_sound
			"Vibrate":
				button.pressed = !Settings.enable_vibration


func _on_button_pressed(button):
	match button.name:
		"Home":
			Settings.save_settings()
			change_screen($MainMenu)
		"Settings":
			change_screen($Settings)
		"Play":
			change_screen(null)
		"Music":
			Settings.enable_music = !button.pressed
		"Sound":
			Settings.enable_sound = !button.pressed
		"Vibrate":
			Settings.enable_vibration = !button.pressed

func change_screen(newScene):
	if currentScene:
		currentScene.disappear()
	if newScene:
		currentScene = newScene
		currentScene.appear()
		yield(currentScene.tween, "tween_completed")
	else:
		yield(currentScene.tween, "tween_completed")
		get_tree().change_scene("res://Scenes/GameScene.tscn")
