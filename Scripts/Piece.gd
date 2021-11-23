extends RigidBody2D

signal piece_placed
signal piece_fell
signal delete_piece

var random = RandomNumberGenerator.new()

var pieceShape : int
var polygon
onready var sprite : Node = get_node("Polygon")
onready var collider : Node = get_node("Collider")

onready var trajectoryLine = get_node("FallTrajectory")

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

func _ready():
	sprite.call_deferred("set_polygon",polygon)
	collider.call_deferred("set_polygon",polygon)
	trajectoryLine.width = rightmost_point*2
	linear_velocity.y = fall_speed
	gravity_scale = 0
	add_to_group("Pieces")

func init(spawn_height, shape = -1):
	position.y = spawn_height
	fall_speed = spawn_height/-10

	random.randomize()
	if shape == -1:
		shape = random.randi_range(0,6)
	pieceShape = shape

	var vertices
	match shape:
		#Square
		0:
			vertices = [Vector2(-32,-32),Vector2(32,-32),Vector2(32,32),Vector2(-32,32)]
			leftmost_point = -32
			rightmost_point = 32
		#Line
		1:
			#Standard
			#vertices = [Vector2(-64,-32),Vector2(64,-16),Vector2(64,0),Vector2(-64,0)]
			#Centered
			vertices = [Vector2(-64,-16),Vector2(64,-16),Vector2(64,16),Vector2(-64,16)]
			leftmost_point = -64
			rightmost_point = 64
		#T
		2:
			vertices = [Vector2(-48,16),Vector2(48,16),Vector2(48,-16),Vector2(16,-16),Vector2(16,-48),Vector2(-16,-48),Vector2(-16,-16),Vector2(-48,-16)]
			
		#L
		3:
			vertices = [Vector2(-48,16),Vector2(48,16),Vector2(48,-16),Vector2(-16,-16),Vector2(-16,-48),Vector2(-48,-48)]
			
		#Backwards L
		4:
			vertices = [Vector2(48,16),Vector2(48,-48),Vector2(16,-48),Vector2(16,-16),Vector2(-48,-16),Vector2(-48,16)]
			
		#S
		5:
			#Standard
			#vertices = [Vector2(-16,16),Vector2(-16,-16),Vector2(48,-16),Vector2(48,16),Vector2(16,16),Vector2(16,48),Vector2(-48,48),Vector2(-48,16)]
			#Centered
			vertices = [Vector2(-16,0),Vector2(-16,-32),Vector2(48,-32),Vector2(48,0),Vector2(16,0),Vector2(16,32),Vector2(-48,32),Vector2(-48,0)]
			
		#Z
		6:
			#Standard
			#vertices = [Vector2(-48,-16),Vector2(16,-16),Vector2(16,16),Vector2(48,16),Vector2(48,48),Vector2(-16,48),Vector2(-16,16),Vector2(-48,16)]
			#Centered
			vertices = [Vector2(-16,0),Vector2(-16,32),Vector2(48,32),Vector2(48,0),Vector2(16,0),Vector2(16,-32),Vector2(-48,-32),Vector2(-48,0)]
			
	if leftmost_point == 0:
		leftmost_point = -48
		rightmost_point = 48
			
	
	polygon = PoolVector2Array(vertices)
	return self


func _integrate_forces(state):
	if falling:
		if onScreen:
			if Input.is_action_just_pressed("drop"):
				drop(state)
			if Input.is_action_pressed("down"):
				if linear_velocity.y != fall_speed*3:
					linear_velocity.y = fall_speed*3
			else:
				if linear_velocity.y != fall_speed:
					linear_velocity.y = fall_speed

			
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
			elif frameNumMove < 4:
				var moveAmount : int = (4-abs(frameNumMove)) * moveDirection
				if test_motion(Vector2(moveAmount,0),false):
					while test_motion(Vector2(moveAmount,0),false) and moveAmount != 0:
						moveAmount -= moveAmount/abs(moveAmount)
					collide(null)
				state.transform.origin.x += moveAmount
				frameNumMove+=1
			else:
				if frameNumMove >= 8:
					moveDirection = 0
				frameNumMove += 1

			if spinDirection == 0:
				if Input.is_action_pressed("rotate_left"):
					spinDirection = -1
					frameNumSpin = -4
				if Input.is_action_pressed("rotate_right"):
					spinDirection = 1
					frameNumSpin = -4
			elif frameNumSpin < 5:
				state.angular_velocity = spinDirection * (5-abs(frameNumSpin)) * 3.834
				frameNumSpin += 1
			else:
				if state.angular_velocity != 0:
					state.angular_velocity = 0
				if frameNumSpin >= 20:
					spinDirection = 0
					rotation_degrees = round(rotation_degrees)
				frameNumSpin += 1
			find_edges()
			# position fall trajectory outline
			if falling:
				if pieceShape == 2:
					trajectoryLine.global_position.x = (leftmost_point+rightmost_point)/2
				elif pieceShape == 3 or pieceShape == 4:
					trajectoryLine.global_position.x = (leftmost_point+rightmost_point)/2
					trajectoryLine.global_position.y = to_global(polygon[3]).y
				trajectoryLine.width = rightmost_point-leftmost_point
				trajectoryLine.global_rotation_degrees = 0
		else:
			drop(state)
			collide(null)
	elif placedPosition.y < position.y-15:
		emit_signal("piece_fell")
		placedPosition = position
	if position.y > 128:
		emit_signal("delete_piece", self)

func collide(_body: Node):
	if falling:
		trajectoryLine.queue_free()
		linear_velocity.y = 0
		linear_velocity.x = moveDirection*abs(moveDirection)*50
		if test_motion(Vector2(0,1)):
			linear_velocity.x = 0
		angular_velocity /= 2
		gravity_scale = 1.0
		falling = false
		placedPosition = position
		set_deferred("contact_monitor", false)
		call_deferred("emit_signal","piece_placed")

func drop(state):
	var moveDistance : int = -position.y+320
	while test_motion(Vector2(0,moveDistance),false):
		moveDistance-=1
	state.transform.origin.y += moveDistance
	state.linear_velocity.y = 0

func find_highest_point():
	var highest_point : float = 0
	for point in polygon:
		var global_y_pos = to_global(point).y
		if global_y_pos < highest_point:
			highest_point = global_y_pos
	return highest_point

func find_edges():
	var left : float = global_position.x
	var right : float = global_position.x
	for i in range(polygon.size()):
		if to_global(polygon[i]).x < left:
			left = to_global(polygon[i]).x
		if to_global(polygon[i]).x > right:
			right = to_global(polygon[i]).x
	leftmost_point = left
	rightmost_point = right


func _on_VisibilityNotifier2D_screen_entered():
	onScreen = true

func _on_VisibilityNotifier2D_screen_exited():
	onScreen = false
	if not falling:
		emit_signal("piece_fell")
