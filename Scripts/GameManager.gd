extends Node2D

var random = RandomNumberGenerator.new()

var pieceSequence : Array
var nextSequence : Array

var pieces : Array
var max_height : float = 0

var pieceScene = preload("res://Scenes/Piece.tscn")
var pieceSpawnHeight : float = -640.0

var lives : int = 3

onready var screenWidth = get_viewport().size.x

onready var camera = get_node("Camera2D")
onready var ui = get_node("UI")
onready var pauseMenu = get_node("Menus/PauseMenu")
onready var gameOverMenu = get_node("Menus/GameOverMenu")


func _ready():
	register_buttons()

	random.randomize()

	for _i in range(7):
		pieceSequence.append(random.randi_range(0,6))
	
	next_piece()


func next_piece():
	find_highest_piece(false)

	var piece = pieceScene.instance(random.randi_range(0,6))
	get_node("Pieces").add_child(piece)
	piece.global_transform.origin = Vector2(0,pieceSpawnHeight)
	pieces.append(piece)
	piece.connect("piece_placed", self, "next_piece")
	piece.connect("piece_fell", self, "find_highest_piece")

	# if numPieces % 7 == 6:
	# 	var tempSequence : Array
	# 	var tooManyOf : Array
	# 	var tooFewOf : Array
	# 	for _i in range(7):

func find_highest_piece(checkAll: bool):
	var numPieces = pieces.size()
	if checkAll:
		var highest : float = 0.0
		for i in range(numPieces):
			if !pieces[i].falling:
				var pieceHeight = pieces[i].find_highest_point()
				if pieceHeight < highest:
					highest = pieceHeight
		max_height = highest
	else:
		if numPieces>=1 and !pieces[numPieces-1].falling:
			var pieceHeight = pieces[numPieces-1].find_highest_point()
			if pieceHeight < max_height:
				max_height = pieceHeight
	
	camera.set_target(max_height)
	pieceSpawnHeight = camera.targetY-((get_viewport().size.y/2)*camera.zoom.y+64)

	
func _on_OutOfBounds_body_entered(body):
	if body.is_in_group("Pieces"):
		if abs(body.linear_velocity.y) > 50:
			pieces.erase(body)
			body.queue_free()
			if body.falling:
				call_deferred("next_piece")
			find_highest_piece(true)
			lives-=1
			ui.update_lives(lives)
			if lives <= 0:
				get_tree().paused = true
				gameOverMenu.appear()

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("Buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button.name])

func _on_button_pressed(name):
	print(name, " pressed")
	match name:
		"Pause":
			get_tree().paused = true
			pauseMenu.appear()
		"Resume":
			get_tree().paused = false
			pauseMenu.disappear()
		"Play":
			clear_screen()
			yield(camera.tween, "tween_completed")
			get_tree().paused = false
			get_tree().reload_current_scene()
		"Home":
			clear_screen()
			yield(camera.tween, "tween_completed")
			get_tree().paused = false
			get_tree().change_scene("res://Scenes/Menus.tscn")


func clear_screen():
	if not camera.tween.is_active():
		camera.tween.interpolate_property(camera, "offset:x", 0, screenWidth, 0.4, Tween.TRANS_BACK)
		ui.disappear()
		pauseMenu.disappear()
		gameOverMenu.disappear()
		camera.tween.start()
