extends "res://Scripts/Menu.gd"

var lives : int = 3

onready var livesBar = get_node("Control/Lives")

func _ready():
	appear()

func update_lives(amount: int):
	lives = amount
	if lives > 0:
		livesBar.rect_size.x = amount * 51
	else:
		livesBar.visible = false
