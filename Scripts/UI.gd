extends "res://Scripts/Menu.gd"

var lives : int = 3
onready var livesBar = get_node("LostLives/Lives")
onready var liveCooldownTimer = get_node("LostLives/LiveCooldownTimer")

var highscore : int = 0
var maxScore : int = 0
onready var scoreText = get_node("Score")

func _ready():
	load_highscore()
	register_buttons()
	appear()

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("ControlButtons")
	if OS.get_name()=="Android" or OS.get_name()=="iOS":
		for button in buttons:
			button.connect("button_down", self, "_on_button_pressed", [button.name])
			button.connect("button_up", self, "_on_button_released", [button.name])
	else:
		$MarginContainer.queue_free()

func _on_button_resized():
	$MarginContainer/Buttons/RightButtons.rect_min_size.x = $MarginContainer/Buttons/RightButtons/AspectRatioContainer/right.rect_size.x


func blink():
	if not liveCooldownTimer.is_stopped(): 
		if int(liveCooldownTimer.time_left/(liveCooldownTimer.wait_time/4.0))%2==0:
			update_lives(lives+1)
		else:
			update_lives()
	
		liveCooldownTimer.get_node("BlinkTimer").start()


func update_lives(amount: int = lives):
	if amount > 0:
		livesBar.visible = true
		livesBar.rect_size.x = amount * 51
	else:
		livesBar.visible = false

func update_score(height = 0):
	var score = round(-height / 32)
	if score > maxScore:
		maxScore = score
		if maxScore > highscore:
			highscore = maxScore
			save_highscore()
	scoreText.text = "Score: " + str(maxScore) + "\nBest: " + str(highscore)

func subtract_life(camera):
	if liveCooldownTimer.is_stopped():
		lives -= 1
		if OS.get_name()=="Android" or OS.get_name()=="iOS":
			Input.vibrate_handheld(200)
		camera.shake(200)
		update_lives()
		liveCooldownTimer.start()
		liveCooldownTimer.get_node("BlinkTimer").start()
	return lives


func load_highscore():
	var f = File.new()
	if f.file_exists(Settings.score_file):
		f.open(Settings.score_file, File.READ)
		highscore = f.get_var()
		f.close()
		update_score()

func save_highscore():
	var f = File.new()
	f.open(Settings.score_file, File.WRITE)
	f.store_var(highscore)
	f.close()


func _on_button_pressed(name):
	Input.action_press(name)

func _on_button_released(name):
	Input.action_release(name)
