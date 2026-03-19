class_name GSnakeClass
extends Node3D

var animimage : Image
var animtexture : ImageTexture
var animmaterial = null

static func Dmakespiralsnakerows(animwidth, animheight):
	var animdata = PackedVector3Array()
	var snakerows = [ ]
	var voff = Vector3(0,0.5,-3)
	for k in range(animheight):
		var snakerow = PackedVector3Array()
		snakerow.resize(animwidth)
		var kt = k*1.0/animheight
		for j in range(animwidth):
			var u = j*1.0/animwidth
			var tu = u*(45 - kt*30)
			var ur = u*(1+u)*0.2 + kt*0.5
			var p1 = Vector3(u*5,sin(tu)*ur,cos(tu)*ur)
			if u < 0.05:
				p1 *= (u*20)*(u*20)
			snakerow.set(j, p1+voff)
		snakerows.append(snakerow)
	#print(snakerows[0])
	return snakerows

static func snakerowstoimage(snakerows):
	var animdata = PackedVector3Array()
	for row in snakerows:
		animdata.append_array(row)
	print("bytedatalength ", len(animdata.to_byte_array()))
	return Image.create_from_data(len(snakerows[0]), len(snakerows), false, Image.FORMAT_RGBF, animdata.to_byte_array())

func loadsnakemotionimg(fname):
	animimage = Image.load_from_file(fname)
	assert (animimage.get_format() == Image.FORMAT_RGBF)
	animtexture = ImageTexture.create_from_image(animimage)
	animmaterial = $GSnakeMesh.get_surface_override_material(0)
	animmaterial.set_shader_parameter("animtexture", animtexture)

	var c00 = animimage.get_pixel(0,0)
	var p00 = Vector3(c00.r, c00.g, c00.b)
	var sntrans = Transform3D(Basis(), p00)
	$ReelCyl.global_transform = sntrans*$ReelCyl/ReelPoint.transform.inverse()



var tweensnakeout = null
var windbackspeed = 2.0
var windoutspeed = 4.0
var tweensnakerewind = null
func _on_reel_cyl_action_pressed(pickable):
	if tweensnakerewind and tweensnakerewind.is_running():
		tweensnakerewind.kill()
		tweensnakerewind = null
	animmaterial.set_shader_parameter("texvtime", 0.0)
	tweensnakeout = get_tree().create_tween()
	tweensnakeout.tween_method(func (x): animmaterial.set_shader_parameter("texutime", x), 1.0, 0.0, windoutspeed)

func _on_reel_cyl_action_released(pickable):
	if tweensnakeout:
		if tweensnakeout.is_running():
			print("Snake reached destination")
			tweensnakeout.kill()
			tweensnakeout = null
			tweensnakerewind = get_tree().create_tween()
			var u0 = animmaterial.get_shader_parameter("texutime")
			tweensnakerewind.tween_method(func (x): animmaterial.set_shader_parameter("texvtime", x), 0.0, 1.0, (1.0-u0)*windbackspeed)

func setsnakepos(u, v):
	animmaterial.set_shader_parameter("texutime", u)
	animmaterial.set_shader_parameter("texvtime", v)

enum {  SNAKE_HIBERNATING, SNAKE_EMERGING, SNAKE_RETRACTING, SNAKE_PLUGGED, SNAKE_DEAD }
var state = SNAKE_HIBERNATING
var emergeextent = 0.0
var retractionprogress = 0.0
var timecountdown = 0.0
var emergerate = 0.5
var retractrate = 1.5
func resetsnake():
	state = SNAKE_HIBERNATING
	emergeextent = 0.0
	retractionprogress = 0.0
	timecountdown = randf_range(1, 3)
	setsnakepos(1-emergeextent, retractionprogress)

func processsnake(delta):
	if state == SNAKE_HIBERNATING:
		timecountdown -= delta
		if timecountdown < 0:
			state = SNAKE_EMERGING
			retractionprogress = 0.0
	elif state == SNAKE_EMERGING:
		emergeextent += delta*emergerate
		if emergeextent >= 1.0:
			emergeextent = 1.0
			state = SNAKE_RETRACTING
		setsnakepos(1-emergeextent, retractionprogress)
	elif state == SNAKE_RETRACTING:
		retractionprogress += retractrate*delta
		if retractionprogress >= 1.0:
			retractionprogress = 1.0
			state = SNAKE_HIBERNATING
			emergeextent = 0.0
			timecountdown = randf_range(1, 3)
		setsnakepos(1-emergeextent, retractionprogress)
