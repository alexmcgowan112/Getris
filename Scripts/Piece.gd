#TODO? - sprites for pieces
#TODO - special pieces (big, low friction, unrotatable, etc) (a slight wind could also make it more fun to play)


extends RigidBody2D

signal piece_placed
signal piece_fell
signal delete_piece

var random = RandomNumberGenerator.new()

var pieceShape : int
var polygon
var color
onready var collider : Node = get_node("Collider")
onready var sprite : Node = collider.get_node("Polygon")

onready var trajectoryLine = get_node("FallTrajectory")

onready var visibilityTracker = get_node("VisibilityNotifier2D")

# movement vars
var falling : bool = true
var fall_speed : float = 64
var moveDirection : int = 0
var frameNumMove : int
var spinDirection: int = 0
var frameNumSpin : int

var leftmost_point : float = 0
var rightmost_point : float = 0

var placedPosition : Vector2 = Vector2()

var onScreen = true

var windDirection = Vector2()


func init(spawn_height, shape = -1, wind = Vector2()):
	windDirection = wind

	position.y = spawn_height
	fall_speed = spawn_height/-10

	random.randomize()
	if shape == -1:
		shape = random.randi_range(0,6)
	pieceShape = shape

	match shape:
		#O (Square)
		0:
			polygon = PoolVector2Array([Vector2(-32,-32),Vector2(32,-32),Vector2(32,32),Vector2(-32,32)])
			leftmost_point = -32
			rightmost_point = 32
			color = Color.cyan
		#I (Line)
		1:
			#Standard
			#polygon = PoolVector2Array([Vector2(-64,-32),Vector2(64,-16),Vector2(64,0),Vector2(-64,0)])
			#Centered
			polygon = PoolVector2Array([Vector2(-64,-16),Vector2(64,-16),Vector2(64,16),Vector2(-64,16)])
			leftmost_point = -64
			rightmost_point = 64
			color = Color.yellow
		#T
		2:
			polygon = PoolVector2Array([Vector2(-48,16),Vector2(48,16),Vector2(48,-16),Vector2(16,-16),Vector2(16,-48),Vector2(-16,-48),Vector2(-16,-16),Vector2(-48,-16)])
			color = Color.mediumpurple
		#L
		3:
			polygon = PoolVector2Array([Vector2(-48,16),Vector2(48,16),Vector2(48,-16),Vector2(-16,-16),Vector2(-16,-48),Vector2(-48,-48)])
			color = Color.orange
		#J
		4:
			polygon = PoolVector2Array([Vector2(48,16),Vector2(48,-48),Vector2(16,-48),Vector2(16,-16),Vector2(-48,-16),Vector2(-48,16)])
			color = Color.blue
		#S
		5:
			#Standard
			#polygon = PoolVector2Array([Vector2(-16,16),Vector2(-16,-16),Vector2(48,-16),Vector2(48,16),Vector2(16,16),Vector2(16,48),Vector2(-48,48),Vector2(-48,16)])
			#Centered
			polygon = PoolVector2Array([Vector2(-16,0),Vector2(-16,-32),Vector2(48,-32),Vector2(48,0),Vector2(16,0),Vector2(16,32),Vector2(-48,32),Vector2(-48,0)])
			color = Color.green
		#Z
		6:
			#Standard
			#polygon = PoolVector2Array([Vector2(-48,-16),Vector2(16,-16),Vector2(16,16),Vector2(48,16),Vector2(48,48),Vector2(-16,48),Vector2(-16,16),Vector2(-48,16)]
			#Centered
			polygon = PoolVector2Array([Vector2(-16,0),Vector2(-16,32),Vector2(48,32),Vector2(48,0),Vector2(16,0),Vector2(16,-32),Vector2(-48,-32),Vector2(-48,0)])
			color = Color.red
	
	color = color.lightened(0.5)
	
	if leftmost_point == 0:
		leftmost_point = -48
		rightmost_point = 48
	
	return self

func _ready():
	sprite.polygon = polygon
	sprite.color = color
	sprite.texture.noise.seed = random.randi()
	collider.polygon = polygon
	trajectoryLine.width = rightmost_point*2
	if pieceShape == 0:
		visibilityTracker.rect.position = Vector2(-32,-32)
		visibilityTracker.rect.end = Vector2(32,32)
	elif pieceShape == 1:
		visibilityTracker.rect.position = Vector2(-64,-16)
		visibilityTracker.rect.end = Vector2(64,16)
	linear_velocity.y = fall_speed
	gravity_scale = 0
	add_to_group("Pieces")


func _integrate_forces(state):
	if falling:
		if onScreen:
			# downward movement
			if Input.is_action_just_pressed("drop"):
				if Settings.enable_sound:
					AudioController.play_whoosh()
				drop(state)
				return
			if Input.is_action_pressed("down"):
				linear_velocity.y = min(fall_speed*3,linear_velocity.y+8)
			else:
				linear_velocity.y = max(fall_speed,linear_velocity.y-8)
			
			# horizontal movement
			if moveDirection == 0:
				if Input.is_action_pressed("shove_left"):
					if leftmost_point >= -288:
						moveDirection = -2
					elif leftmost_point >= -304:
						moveDirection = -1
				elif Input.is_action_pressed("left"):
					if leftmost_point >= -304:
						moveDirection = -1
				if Input.is_action_pressed("shove_right"):
					if rightmost_point <= 288:
						moveDirection = 2
					elif rightmost_point <= 304:
						moveDirection = 1
				elif Input.is_action_pressed("right"):
					if rightmost_point <= 304:
						moveDirection = 1
				if moveDirection != 0:
					frameNumMove = -3
					if Settings.enable_sound:
						AudioController.play_whoosh()
			elif frameNumMove < 4:
				var moveAmount : int = (4-abs(frameNumMove)) * moveDirection
				if test_motion(Vector2(moveAmount,0),false):
					while test_motion(Vector2(moveAmount,0),false) and moveAmount != 0:
						moveAmount -= sign(moveAmount)
					collide(state)
				state.transform.origin.x += moveAmount
				frameNumMove+=1
			else:
				if frameNumMove >= 8:
					moveDirection = 0
				frameNumMove += 1

			# rotational movement
			if spinDirection == 0:
				if Input.is_action_pressed("rotate_left"):
					spinDirection = -1
				if Input.is_action_pressed("rotate_right"):
					spinDirection = 1
				if spinDirection != 0:
					frameNumSpin = -4
					if Settings.enable_sound:
						AudioController.play_whoosh()
			elif frameNumSpin < 5:
				state.angular_velocity = spinDirection * (5-abs(frameNumSpin)) * 3.834
				frameNumSpin += 1
			else:
				state.angular_velocity = 0
				if frameNumSpin >= 20:
					spinDirection = 0
					state.transform = state.transform.orthonormalized()
				frameNumSpin += 1
			
			# position trajectory outline
			find_edges()
			if falling:
				if pieceShape == 2:
					trajectoryLine.global_position.x = (leftmost_point+rightmost_point)/2
				elif pieceShape == 3 or pieceShape == 4:
					trajectoryLine.global_position.x = (leftmost_point+rightmost_point)/2
					trajectoryLine.global_position.y = to_global(polygon[3]).y
				trajectoryLine.width = rightmost_point-leftmost_point
				trajectoryLine.global_rotation_degrees = 0
				
				#check if the piece has or is about to collide
				if test_motion(Vector2(0,0.64),false) or state.get_contact_count() > 0:
					collide(state)
		
	# if the piece is already placed, check if it has moved
	elif placedPosition.y < position.y-15:
		emit_signal("piece_fell")
		placedPosition = position
		applied_force = windDirection*position.y/-32
	# check if the piece has fallen below the world
	if position.y > 128:
		emit_signal("delete_piece", self)

func collide(state):
	if falling:
		trajectoryLine.queue_free()
		state.linear_velocity.y = 0
		if test_motion(Vector2(0,0.64),false):
			state.linear_velocity.x = 0
		else:
			state.linear_velocity.x = moveDirection*abs(moveDirection)*50
		state.angular_velocity /= 2
		gravity_scale = 1.0
		falling = false
		match pieceShape:
			2:
				collider.position.y = 4
				state.transform = state.transform.translated(Vector2(0,-4))
			3:
				collider.position = Vector2(4,4)
				state.transform = state.transform.translated(Vector2(-4,-4))
			4:
				collider.position = Vector2(-4,4)
				state.transform = state.transform.translated(Vector2(4,-4))

		placedPosition = state.transform.origin
		global_position = state.transform.origin
		applied_force = windDirection*position.y/-32
		set_deferred("contact_monitor", false)
		call_deferred("emit_signal", "piece_placed")


func drop(state):
	var moveDistance : int = -position.y+320
	while test_motion(Vector2(0,moveDistance),false):
		moveDistance-=1
	state.transform.origin.y += moveDistance
	collide(state)


func find_highest_point():
	if is_inside_tree():
		var highest_point : float = 0
		for point in polygon:
			highest_point = min(to_global(point).y,highest_point)
		return highest_point
	return 0

func find_edges():
	var left : float = global_position.x
	var right : float = global_position.x
	for point in polygon:
		var global_x_pos = to_global(point).x
		left = min(global_x_pos,left)
		right = max(global_x_pos,right)
	leftmost_point = left
	rightmost_point = right


func _on_VisibilityNotifier2D_screen_entered():
	onScreen = true

func _on_VisibilityNotifier2D_screen_exited():
	onScreen = false
	if not falling:
		emit_signal("piece_fell")
