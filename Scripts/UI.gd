extends "res://Scripts/Menu.gd"

var lives : int = 3

onready var livesBar = get_node("Lives")

func _ready():
	register_buttons()
	appear()

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("ControlButtons")
	for button in buttons:
		button.connect("button_down", self, "_on_button_pressed", [button.name])
		button.connect("button_up", self, "_on_button_released", [button.name])

func _on_button_pressed(name):
	Input.action_press(name)

func _on_button_released(name):
	Input.action_release(name)

func update_lives(amount: int):
	lives = amount
	if lives > 0:
		livesBar.rect_size.x = amount * 51
	else:
		livesBar.visible = false
