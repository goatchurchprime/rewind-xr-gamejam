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
	$RedZone.get_surface_override_material(0).albedo_color.a = clamp(handvelocity.length()/10, 0, 1)
