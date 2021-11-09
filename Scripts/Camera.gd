extends Camera2D


var targetY : float = -256
var currentZoom : float = 1.0
var adjustSpeed : int = 100

func _physics_process(delta):
	if abs(targetY - position.y) > 10:
		var moveTo = smoothly_approach_value(position.y,targetY)
		# move camera up
		if moveTo < position.y:
			if currentZoom < 1.5 and position.y >= zoom_amount_2_pos(1.5):
				currentZoom = pos_2_zoom_amount(moveTo)
				if currentZoom > 1.5:
					currentZoom = 1.5
				zoom = Vector2(currentZoom, currentZoom)
				scale = zoom
			position.y = moveTo
		# move camera down
		elif moveTo > position.y:
			if position.y >= zoom_amount_2_pos(1.5):
				currentZoom = pos_2_zoom_amount(moveTo)
				if currentZoom < 1.0:
					currentZoom = 1.0
				zoom = Vector2(currentZoom, currentZoom)
				scale = zoom
			position.y = moveTo

func smoothly_approach_value(from, to):
	var move_to : float
	move_to = (to - from)/adjustSpeed + from
	return move_to

func zoom_amount_2_pos(zoomAmount):
	return -(get_viewport().size.y/2)*zoomAmount+64

func pos_2_zoom_amount(pos):
	return (pos-64)/-(get_viewport().size.y/2)


func set_target(value):
	targetY = value
	if targetY > zoom_amount_2_pos(1):
		targetY = zoom_amount_2_pos(1)
