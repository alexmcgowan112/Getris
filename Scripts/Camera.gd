extends Camera2D


var targetY : float = -256
var adjustTime : float = 1.5

onready var tween = get_node("Tween")

onready var screenHeight = (get_viewport().size.y/get_viewport().size.x)*640

func _ready():
	tween.interpolate_property(self, "offset:x", -800, 0, 0.5, Tween.TRANS_BACK)
	tween.start()
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func update_camera():
	if position.y >= zoom_amount_2_pos(1.5):
		var targetZoom = clamp(pos_2_zoom_amount(targetY),1.0,1.5)
		tween.interpolate_property(self, "zoom", Vector2(zoom.y,zoom.y), Vector2(targetZoom,targetZoom), adjustTime, tween.TRANS_SINE)
	tween.interpolate_property(self, "position", Vector2(position.x,position.y), Vector2(position.x,targetY), adjustTime, tween.TRANS_SINE)
	tween.start()


func zoom_amount_2_pos(zoomAmount):
	return -(screenHeight/2)*zoomAmount+64

func pos_2_zoom_amount(pos):
	return (pos-64)/-(screenHeight/2)

func set_target(value):
	targetY = min(value,zoom_amount_2_pos(1))
	if abs(targetY - position.y) >= 16:
		update_camera()


#camera shake
export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 50)  # Maximum horizontal/vertical shake in pixels.
export var max_rot = 0.1  # Maximum rotation (in radians)
var trauma = 0.0  # Current shake strength.
onready var noise = OpenSimplexNoise.new() #using noise instead of random allows smoother shaking
var noise_y = 0

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, 1.5)
	noise_y += 1
	rotation = max_rot * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	AudioController.play_rumble(60*(trauma-1))

func set_trauma(amount):
	add_trauma(max(amount-trauma,0))
