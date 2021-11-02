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
		0:
			vertices = [Vector2(-64,-64),Vector2(64,-64),Vector2(64,64),Vector2(-64,64)]
		1:
			vertices = [Vector2(-128,-64),Vector2(128,-64),Vector2(128,0),Vector2(-128,0)]
		2:
			vertices = [Vector2(-96,-32),Vector2(96,-32),Vector2(96,32),Vector2(32,32),Vector2(32,96),Vector2(-32,96),Vector2(-32,32),Vector2(-96,32)]
		3:
			vertices = [Vector2(-96,-32),Vector2(96,-32),Vector2(96,32),Vector2(-32,32),Vector2(-32,96),Vector2(-96,96)]
		4:
			vertices = [Vector2(-96,-32),Vector2(96,-32),Vector2(96,96),Vector2(32,96),Vector2(32,32),Vector2(-96,32)]
		5:
			vertices = [Vector2(-32,32),Vector2(-32,-32),Vector2(96,-32),Vector2(96,32),Vector2(32,32),Vector2(32,96),Vector2(-96,96),Vector2(-96,32)]
		6:
			vertices = [Vector2(-96,-32),Vector2(32,-32),Vector2(32,32),Vector2(96,32),Vector2(96,96),Vector2(-32,96),Vector2(-32,32),Vector2(-96,32)]
	
	polygon = PoolVector2Array(vertices)
	if sprite != null:
		sprite.set_polygon(polygon)
		collider.set_polygon(polygon)

func collide(_body: Node):
	if get_mode() == MODE_KINEMATIC:
		if Input.is_action_pressed("drop"):
			position.y-=32
		elif Input.is_action_pressed("down"):
			position.y-=drop_speed
		else:
			position.y-=fall_speed
		linear_velocity.y = 0
		set_mode(MODE_RIGID)
		mainScene.next_piece()

func _physics_process(_delta):
	if mode == MODE_KINEMATIC:
		if Input.is_action_pressed("drop"):
			move(32)
		elif Input.is_action_pressed("down"):
			move(drop_speed)
		else:
			move(fall_speed)

func move(amount):
	if test_motion(Vector2(0,amount),false,0.0):
		mode = MODE_RIGID
	else:
		position.y+=amount
