extends RigidBody2D


signal piece_placed

var random = RandomNumberGenerator.new()

var polygon
onready var sprite : Node = get_node("Polygon")
onready var collider : Node = get_node("Collider")

onready var mainScene : Node = get_parent().get_parent()

# movement vars
var falling : bool = true
var fall_speed : float = 100
var drop_speed : float = 250
var moveDirection : int = 0
var frameNumMove : int
var spinDirection: int = 0
var frameNumSpin : int

func _ready():
	if sprite != null:
		sprite.set_polygon(polygon)
		collider.set_polygon(polygon)
	linear_velocity.y = fall_speed
	gravity_scale = 0
	add_to_group("Pieces")

func _init(shape = -1):
	random.randomize()
	if shape == -1:
		shape = random.randi_range(0,6)

	var vertices
	match shape:
		#Square
		0:
			vertices = [Vector2(-32,-32),Vector2(32,-32),Vector2(32,32),Vector2(-32,32)]
		#Line
		1:
			#Standard
			#vertices = [Vector2(-64,-32),Vector2(64,-16),Vector2(64,0),Vector2(-64,0)]
			#Centered
			vertices = [Vector2(-64,-16),Vector2(64,-16),Vector2(64,16),Vector2(-64,16)]
		#T
		2:
			vertices = [Vector2(-48,16),Vector2(48,16),Vector2(48,-16),Vector2(16,-16),Vector2(16,-48),Vector2(-16,-48),Vector2(-16,-16),Vector2(-48,-16)]
		#L
		3:
			vertices = [Vector2(-48,16),Vector2(48,16),Vector2(48,-16),Vector2(-16,-16),Vector2(-16,-48),Vector2(-48,-48)]
		#Backwards L
		4:
			vertices = [Vector2(-48,16),Vector2(48,16),Vector2(48,-48),Vector2(16,-48),Vector2(16,-16),Vector2(-48,-16)]
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
			
	
	polygon = PoolVector2Array(vertices)
	if sprite != null:
		sprite.set_polygon(polygon)
		collider.set_polygon(polygon)


func _integrate_forces(state):
	if falling:
		if Input.is_action_just_pressed("drop"):
			drop(state)
		if Input.is_action_pressed("down"):
			if linear_velocity.y != drop_speed:
				linear_velocity.y = drop_speed
		else:
			if linear_velocity.y != fall_speed:
				linear_velocity.y = fall_speed

		
		if moveDirection == 0:
			if Input.is_action_just_pressed("shove_left"):
				moveDirection = -2
			elif Input.is_action_pressed("left"):
				moveDirection = -1
			if Input.is_action_just_pressed("shove_right"):
				moveDirection = 2
			elif Input.is_action_pressed("right"):
				moveDirection = 1	
			if moveDirection != 0:
				frameNumMove = -3
		elif frameNumMove < 4:
			var moveAmount : int = (4-abs(frameNumMove)) * moveDirection
			if test_motion(Vector2(moveAmount,0),false):
				while test_motion(Vector2(moveAmount,0),false):
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


func collide(_body: Node):
	if falling:
		linear_velocity.y = 0
		linear_velocity.x = moveDirection*abs(moveDirection)*50
		angular_velocity /= 2
		gravity_scale = 1.0
		falling = false
		emit_signal("piece_placed")

func drop(state):
	var moveDistance : int = 1000
	while test_motion(Vector2(0,moveDistance),false):
		moveDistance-=1
	state.transform.origin.y += moveDistance
	state.linear_velocity.y = 0
