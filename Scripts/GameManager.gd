#TODO? - Alternative gamemodes (small platform, difficult pieces, etc)

extends Node2D

var random = RandomNumberGenerator.new()

var sequenceIndex : int = 0
var pieceSequence : Array = [0,1,2,3,4,5,6]
var nextSequence : Array = [0,1,2,3,4,5,6]

var pieces : Array
var max_height : float = 0

var pieceScene = preload("res://Scenes/Piece.tscn")
var pieceSpawnHeight : float
var currentPiece

var lives : int = 3

onready var screenHeight = (get_viewport().size.y/get_viewport().size.x)*640

onready var camera = get_node("Camera2D")
onready var ui = get_node("UI")
onready var pauseMenu = get_node("Menus/PauseMenu")
onready var gameOverMenu = get_node("Menus/GameOverMenu")

func _ready():
	register_buttons()

	set_highscore_line()

	random.randomize()

	for i in range(7):
		nextSequence[i] = random.randi_range(0,6)
	create_sequence()

	pieceSpawnHeight = -screenHeight - 64
	next_piece()

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("Buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button.name])

func set_highscore_line():
	if ui.highscore == 0:
		$HighscoreLine.queue_free()
	else:
		$HighscoreLine.rect_position.y = ui.highscore*-32-4
		yield(camera.tween, "tween_completed")
		$HighscoreLine.rect_position.x = -480
		$HighscoreLine.rect_size.x = 960


func _process(delta):
	if currentPiece.position.y >= camera.position.y+16:
		camera.position.y += (currentPiece.position.y - camera.position.y)*delta


# Creates sequences of pieces 7 at a time. If a sequence is missing any pieces, the next one is guaranteed to have those missing pieces.
func create_sequence():
	pieceSequence = nextSequence.duplicate()

	var missing = [0,1,2,3,4,5,6]
	
	for piece in pieceSequence:
		missing.erase(piece)

	for i in range(7):
		nextSequence[i] = random.randi_range(0,6)
		missing.erase(nextSequence[i])

		if 7-i <= missing.size():
			missing.shuffle()
			nextSequence[i] = missing[0]
			missing.remove(0)

func find_highest_piece(checkAll: bool = true):
	var numPieces = pieces.size()
	if numPieces>0:
		if checkAll:
			var highest : float = 0.0
			for i in range(numPieces):
				if !pieces[i].falling:
					var pieceHeight = pieces[i].find_highest_point()
					if pieceHeight < highest:
						highest = pieceHeight
			max_height = highest
		else:
			var pieceHeight = pieces[numPieces-1].find_highest_point()
			if pieceHeight < max_height:
				max_height = pieceHeight
	ui.update_score(max_height)
	camera.set_target(max_height)
	screenHeight = (get_viewport().size.y/get_viewport().size.x)*640
	pieceSpawnHeight = camera.targetY-((screenHeight/2)*camera.zoom.y+64)

func next_piece():
	call_deferred("find_highest_piece",false)
	if currentPiece:
		pieces.append(currentPiece)

	var piece = pieceScene.instance().init(pieceSpawnHeight, pieceSequence[sequenceIndex])
	currentPiece = piece
	get_node("Pieces").add_child(piece)
	piece.connect("piece_placed", self, "next_piece")
	piece.connect("piece_fell", self, "find_highest_piece")
	piece.connect("delete_piece", self, "delete_piece")

	sequenceIndex += 1
	if sequenceIndex >= 7:
		create_sequence()
		sequenceIndex = 0

func delete_piece(piece):
	pieces.erase(piece)
	if piece.falling:
		call_deferred("next_piece")
	piece.queue_free()
	find_highest_piece()
	lives=ui.subtract_life(camera)
	if lives <= 0:
		get_tree().paused = true
		gameOverMenu.appear()


func _on_button_pressed(name):
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
		camera.tween.interpolate_property(camera, "offset:x", 0, 960, 0.4, Tween.TRANS_BACK)
		ui.disappear()
		pauseMenu.disappear()
		gameOverMenu.disappear()
		camera.tween.start()
