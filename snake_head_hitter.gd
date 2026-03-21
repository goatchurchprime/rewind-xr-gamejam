extends Area3D

const bsize = 5
var prevpositiontimes = PackedVector3Array()
var ipos = 0
var handvelocity = Vector3(0,0,0)
func _ready():
	prevpositiontimes.resize(bsize)
func _physics_process(delta):
	prevpositiontimes[ipos] = global_position
	ipos = ((ipos + 1) % bsize)
	handvelocity = (prevpositiontimes[ipos] - global_position)/(delta*bsize)
	#ee$RedZone.get_surface_override_material(0).albedo_color.a = clamp(handvelocity.length()/10, 0, 1)

var tweencolour : Tween = null
@onready var rzmat = $RedZone.get_surface_override_material(0)
const speedtohit = 2.0
func checksnakehit(snakeheadvec):
	var relhandhit = -snakeheadvec.dot(handvelocity)
	#var relhandhit = handvelocity.length()
	print("relhandhit ", relhandhit)
	if tweencolour and tweencolour.is_running():
		tweencolour.kill()
	tweencolour = get_tree().create_tween()
	if relhandhit > speedtohit:
		rzmat.albedo_color = Color.RED
		tweencolour.tween_method(func(x): rzmat.albedo_color.a = x, 0.5, 0.0, 0.89)
		return true
	elif relhandhit > 0.0:
		var yvalstart = (relhandhit/speedtohit)*0.5
		if yvalstart > rzmat.albedo_color.a:
			rzmat.albedo_color = Color.YELLOW
			tweencolour.tween_method(func(x): rzmat.albedo_color.a = x, yvalstart, 0.0, yvalstart*1.1)
	return false
