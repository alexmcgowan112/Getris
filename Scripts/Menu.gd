extends CanvasLayer


onready var tween = get_node("Tween")


func appear():
	if offset.x != 0:
		tween.interpolate_property(self, "offset:x", 640, 0, 0.5, Tween.TRANS_BACK)
		tween.start()

func disappear():
	if offset.x == 0:
		tween.interpolate_property(self, "offset:x", 0, -640, 0.4, Tween.TRANS_BACK)
		tween.start()
