extends RigidBody2D


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

func _init(shape = -1):
	random.randomize()
	if shape == -1:
		shape = random.randi_range(5,6)

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


func _physics_process(_delta):
	if falling:
		#if Input.is_action_just_pressed("drop"):
			#movement.y = 600
		if Input.is_action_pressed("down"):
			if linear_velocity.y != drop_speed:
				linear_velocity.y = drop_speed
		else:
			if linear_velocity.y != fall_speed:
				linear_velocity.y = fall_speed

		
		if moveDirection == 0:
			if Input.is_action_pressed("left"):
				moveDirection = -1
				frameNumMove = -3
			if Input.is_action_pressed("right"):
				moveDirection = 1
				frameNumMove = -3
				
		else:
			if moveDirection == -1:
				linear_velocity.x = -(4-abs(frameNumMove))*64.11
			else:
				linear_velocity.x = (4-abs(frameNumMove))*64.11
			frameNumMove+=1
			if frameNumMove >= 4:
				moveDirection = 0
				linear_velocity.x = 0
				position.x = round(position.x)

		if spinDirection == 0:
			if Input.is_action_pressed("rotate_left"):
				spinDirection = -1
				frameNumSpin = -9
			if Input.is_action_pressed("rotate_right"):
				spinDirection = 1
				frameNumSpin = -9
		else:
			if spinDirection == -1:
				angular_velocity = -(10-abs(frameNumSpin))+0.175
			else:
				angular_velocity = (10-abs(frameNumSpin))-0.175
			frameNumSpin += 1
			if frameNumSpin >= 10:
				spinDirection = 0
				angular_velocity = 0
				rotation_degrees = round(rotation_degrees)


func collide(body: Node):
	gravity_scale = 1.0
	falling = false
