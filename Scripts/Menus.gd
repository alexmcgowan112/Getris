#TODO - SFX
#TODO - settings

extends Node


onready var currentScene = $MainMenu

func _ready():
	register_buttons()
	change_screen(currentScene)

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("Buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button.name])

func _on_button_pressed(name):
	match name:
		"Home":
			change_screen($MainMenu)
		"Settings":
			change_screen($Settings)
		"Play":
			change_screen(null)

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
