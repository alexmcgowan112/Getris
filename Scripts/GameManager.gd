extends Node2D

var random = RandomNumberGenerator.new()

var pieceSequence : Array
var nextSequence : Array

var pieces : Array
var max_height : float = 0

var pieceScene = preload("res://Scenes/Piece.tscn")
var pieceSpawnHeight : float = -640.0

onready var camera = get_node("Camera2D")
#To do: make camera and block start position stretch with average/top piece position

func _ready():
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
	var _a = piece.connect("piece_placed", self, "next_piece")

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
	# var zoomAmount = max_height/-320.0
	# if zoomAmount < 1:
	# 	zoomAmount = 1
	# cameraZoom = zoomAmount
	# print(cameraZoom)
	camera.set_target(max_height)
	pieceSpawnHeight = -640*camera.currentZoom

	
func _on_OutOfBounds_body_entered(body):
	if body.is_in_group("Pieces"):
		pieces.erase(body)
		body.queue_free()
		if body.falling:
			next_piece()
		find_highest_piece(true)
