extends RigidBody2D

class_name Piece

# shapes: Square, Line, T, L, Reverse L, S, Z

var random = RandomNumberGenerator.new()

export var fall_speed : float = 1.0
export var drop_speed : float = 3.2

var polygon
onready var sprite : Node = get_node("Polygon")
onready var collider : Node = get_node("Collider")

onready var mainScene : Node = get_parent().get_parent()

# 0 = none, 1 = left, 2 = right, 3 = rotate left, 4 = rotate right
var moveDirection : int = 0
var frameNumMove : int
var spinDirection: int = 0
var frameNumSpin : int

func _ready():
	if sprite != null:
		sprite.set_polygon(polygon)
		collider.set_polygon(polygon)
	linear_velocity.y = fall_speed

func _init(shape = -1):
	random.randomize()
	if shape == -1:
		shape = random.randi_range(0,6)

	var vertices
	match shape:
		#Square
		0:
			vertices = [Vector2(-64,-64),Vector2(64,-64),Vector2(64,64),Vector2(-64,64)]
		#Line
		1:
			#Standard
			#vertices = [Vector2(-128,-64),Vector2(128,-64),Vector2(128,0),Vector2(-128,0)]
			#Centered
			vertices = [Vector2(-128,-32),Vector2(128,-32),Vector2(128,32),Vector2(-128,32)]
		#T
		2:
			vertices = [Vector2(-96,-32),Vector2(96,-32),Vector2(96,32),Vector2(32,32),Vector2(32,96),Vector2(-32,96),Vector2(-32,32),Vector2(-96,32)]
		#L
		3:
			vertices = [Vector2(-96,-32),Vector2(96,-32),Vector2(96,32),Vector2(-32,32),Vector2(-32,96),Vector2(-96,96)]
		#Backwards L
		4:
			vertices = [Vector2(-96,-32),Vector2(96,-32),Vector2(96,96),Vector2(32,96),Vector2(32,32),Vector2(-96,32)]
		#S
		5:
			#Standard
			#vertices = [Vector2(-32,32),Vector2(-32,-32),Vector2(96,-32),Vector2(96,32),Vector2(32,32),Vector2(32,96),Vector2(-96,96),Vector2(-96,32)]
			#Centered
			vertices = [Vector2(-32,0),Vector2(-32,-64),Vector2(96,-64),Vector2(96,0),Vector2(32,0),Vector2(32,64),Vector2(-96,64),Vector2(-96,0)]
		#Z
		6:
			#Standard
			#vertices = [Vector2(-96,-32),Vector2(32,-32),Vector2(32,32),Vector2(96,32),Vector2(96,96),Vector2(-32,96),Vector2(-32,32),Vector2(-96,32)]
			#Centered
			vertices = [Vector2(-96,-64),Vector2(32,-64),Vector2(32,0),Vector2(96,0),Vector2(96,64),Vector2(-32,64),Vector2(-32,0),Vector2(-96,0)]
	
	polygon = PoolVector2Array(vertices)
	if sprite != null:
		sprite.set_polygon(polygon)
		collider.set_polygon(polygon)

# func collide(_body: Node):
# 	if get_mode() == MODE_KINEMATIC:
# 		if Input.is_action_pressed("drop"):
# 			position.y-=32
# 		elif Input.is_action_pressed("down"):
# 			position.y-=drop_speed
# 		else:
# 			position.y-=fall_speed
# 		linear_velocity.y = 0
# 		set_mode(MODE_RIGID)
# 		mainScene.next_piece()

func _physics_process(_delta):
	if mode == MODE_KINEMATIC:
		var movement : Vector2 = Vector2()
		if Input.is_action_just_pressed("drop"):
			movement.y = 600
		elif Input.is_action_pressed("down"):
			movement.y = drop_speed
		else:
			movement.y = fall_speed
		
		if moveDirection == 0:
			if Input.is_action_just_pressed("left"):
				moveDirection = -1
				frameNumMove = -3
			if Input.is_action_just_pressed("right"):
				moveDirection = 1
				frameNumMove = -3
				
		else:
			if moveDirection == -1:
				movement.x = -(4-abs(frameNumMove))
			else:
				movement.x = 4-abs(frameNumMove)
			frameNumMove+=1
			if frameNumMove >= 4:
				moveDirection = 0

		if spinDirection == 0:
			if Input.is_action_just_pressed("rotate_left"):
				spinDirection = -1
				frameNumSpin = -8
			if Input.is_action_just_pressed("rotate_right"):
				spinDirection = 1
				frameNumSpin = -8
		else:
			if spinDirection == -1:
				rotation_degrees += -(9.5-abs(frameNumSpin-0.5))
			else:
				rotation_degrees += 9.5-abs(frameNumSpin-0.5)
			frameNumSpin += 1
			if frameNumSpin >= 10:
				spinDirection = 0
				
		move(movement)


func move(movement : Vector2):
	while test_motion(movement):
		movement -= movement.normalized()
		if movement.y <= 0 or movement.x != 0:
			set_mode(MODE_RIGID)
			linear_velocity = Vector2()
			sleeping = false
			break
	position+=movement
