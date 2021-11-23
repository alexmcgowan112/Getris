extends "res://Scripts/Menu.gd"

var lives : int = 3

onready var livesBar = get_node("LostLives/Lives")
onready var liveCooldownTimer = get_node("LostLives/LiveCooldownTimer")

func _ready():
	register_buttons()
	appear()

func _process(_delta):
	if not liveCooldownTimer.is_stopped() and int(liveCooldownTimer.time_left/(liveCooldownTimer.wait_time/4.0))%2==0:
		update_lives(lives+1)
	else:
		update_lives()

func subtract_life():
	if liveCooldownTimer.is_stopped():
		lives -= 1
		if OS.get_name()=="Android" or OS.get_name()=="iOS":
			Input.vibrate_handheld(200)
		update_lives()
		liveCooldownTimer.start()
	return lives

func update_lives(amount: int = lives):
	if amount > 0:
		if livesBar.rect_size.x != amount * 51:
			livesBar.rect_size.x = amount * 51
	else:
		if livesBar.visible:
			livesBar.visible = false

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("ControlButtons")
	if OS.get_name()=="Android" or OS.get_name()=="iOS":
		for button in buttons:
			button.connect("button_down", self, "_on_button_pressed", [button.name])
			button.connect("button_up", self, "_on_button_released", [button.name])
	else:
		$MarginContainer.queue_free()

func _on_button_pressed(name):
	Input.action_press(name)

func _on_button_released(name):
	Input.action_release(name)

func _on_button_resized():
	$MarginContainer/Buttons/RightButtons.rect_min_size.x = $MarginContainer/Buttons/RightButtons/AspectRatioContainer/right.rect_size.x
