extends Node2D

var random = RandomNumberGenerator.new()

var pieceSequence : Array
var nextSequence : Array

var pieces : Array

var pieceScene = preload("res://Scenes/Piece.tscn")

func _ready():
	random.randomize()

	for _i in range(7):
		pieceSequence.append(random.randi_range(0,6))
	
	next_piece()

func next_piece():
	var piece = pieceScene.instance(random.randi_range(0,6))
	get_node("Pieces").add_child(piece)
	piece.global_transform.origin = Vector2(0,-608)

	var _a = piece.connect("piece_placed", self, "next_piece")

	# if numPieces % 7 == 6:
	# 	var tempSequence : Array
	# 	var tooManyOf : Array
	# 	var tooFewOf : Array
	# 	for _i in range(7):
			
