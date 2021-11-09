extends Camera2D


var targetY : float = -256
var currentZoom : float = 1.0

func _physics_process(delta):
	print(position.y, " to ", targetY)
	print("Zoom = ", currentZoom)
	if targetY - position.y < -8:
		if currentZoom < 1.5:
			currentZoom -= (targetY - position.y)/10000.0
			if currentZoom > 1.5:
				currentZoom = 1.5
			position.y = -320.0*currentZoom+64
			zoom = Vector2(currentZoom, currentZoom)
		else:
			position.y += (targetY - position.y)/100.0
	elif targetY - position.y > 8:
		if position.y <= -576:
			currentZoom += (targetY - position.y)/10000.0
			if currentZoom < 1.0:
				currentZoom = 1.0
			position.y = -320.0*currentZoom+64
			zoom = Vector2(currentZoom, currentZoom)
		else:
			position.y += (targetY - position.y)/100.0



func set_target(value):
	targetY = value
	if targetY > -256.0:
		targetY = -256.0
