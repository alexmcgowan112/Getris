extends Camera2D


var targetY : float = -256
var adjustTime : float = 1.5

onready var tween = get_node("Tween")

func _ready():
	tween.interpolate_property(self, "offset:x", -496, 0, 0.5, Tween.TRANS_BACK)
	tween.start()

func update_camera():
	if position.y >= zoom_amount_2_pos(1.5):
		var targetZoom = pos_2_zoom_amount(targetY)
		if targetZoom > 1.5:
			targetZoom = 1.5
		if targetZoom < 1.0:
			targetZoom = 1.0
		tween.interpolate_property(self, "zoom", Vector2(zoom.y,zoom.y), Vector2(targetZoom,targetZoom), adjustTime, tween.TRANS_SINE)
		tween.interpolate_property(self, "scale", Vector2(zoom.y,zoom.y), Vector2(targetZoom,targetZoom), adjustTime, tween.TRANS_SINE)
	tween.interpolate_property(self, "position", Vector2(position.x,position.y), Vector2(position.x,targetY), adjustTime, tween.TRANS_SINE)
	tween.start()

func zoom_amount_2_pos(zoomAmount):
	return -(get_viewport().size.y/2)*zoomAmount+64

func pos_2_zoom_amount(pos):
	return (pos-64)/-(get_viewport().size.y/2)

func set_target(value):
	targetY = value
	if targetY > zoom_amount_2_pos(1):
		targetY = zoom_amount_2_pos(1)
	update_camera()
