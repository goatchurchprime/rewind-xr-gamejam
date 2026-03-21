class_name GSnakeClass
extends Node3D

var animimage : Image
var animtexture : Texture2D
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

func loadsnakemotionimg(fname, fromresourceloader):
	if fromresourceloader:
		animtexture = ResourceLoader.load(fname)
		animimage = animtexture.get_image()
	else:
		animimage = Image.load_from_file(fname)
		animtexture = ImageTexture.create_from_image(animimage)
	assert (animimage.get_format() == Image.FORMAT_RGBF)
	animmaterial = $GSnakeMesh.get_surface_override_material(0)
	animmaterial.set_shader_parameter("animtexture", animtexture)

	var c00 = animimage.get_pixel(0,0)
	var c01 = animimage.get_pixel(1,0)
	var p00 = Vector3(c00.r, c00.g, c00.b)
	var p01f = Vector3(c01.r, c00.g, c01.b)
	$ReelDirectionMarker3D.look_at_from_position(p00, p00 - (p01f - p00))
	$ReelCyl.global_transform = $ReelDirectionMarker3D.global_transform*$ReelCyl/ReelPoint.transform.inverse()
	animmaterial.set_shader_parameter("zcyldir", $ReelCyl.global_transform.basis.z)

# All materials to be set through this so we can calculate the position of the head
func setsnakepos(u, v):
	animmaterial.set_shader_parameter("texutime", u)
	animmaterial.set_shader_parameter("texvtime", v)
	var su = (1-u)*animimage.get_width()
	var sv = v*animimage.get_height()
	var iu = clampi(int(su), 0, animimage.get_width()-2)
	var iv = clampi(int(sv), 0, animimage.get_height()-2)
	var fu = clamp(su - iu, 0.0, 1.0)
	var fv = clamp(sv - iv, 0.0, 1.0)
	var c00 = animimage.get_pixel(iu, iv)
	var c10 = animimage.get_pixel(iu+1, iv)
	var c01 = animimage.get_pixel(iu, iv+1)
	var c11 = animimage.get_pixel(iu+1, iv+1)
	var p00 = Vector3(c00.r, c00.g, c00.b)
	var p10 = Vector3(c10.r, c10.g, c10.b)
	var p01 = Vector3(c01.r, c01.g, c01.b)
	var p11 = Vector3(c11.r, c11.g, c11.b)
	var p0l = p00*(1-fv) + p01*fv
	var p1l = p10*(1-fv) + p11*fv
	var pc = p0l*(1-fu) + p1l*fu
	var vc = p1l - p0l
	$SnakeHead.look_at_from_position(pc, pc+vc)
	$SnakeHeadArea.look_at_from_position(pc, pc+vc)
	
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
	tweensnakeout.tween_method(func (x): setsnakepos(x, 0.0), 1.0, 0.0, windoutspeed)

func _on_reel_cyl_action_released(pickable):
	if tweensnakeout:
		if tweensnakeout.is_running():
			print("Snake reached destination")
			tweensnakeout.kill()
			tweensnakeout = null
			tweensnakerewind = get_tree().create_tween()
			var u0 = animmaterial.get_shader_parameter("texutime")
			tweensnakerewind.tween_method(func (x): setsnakepos(u0, x), 0.0, 1.0, (1.0-u0)*windbackspeed)

enum {  SNAKE_HIBERNATING, SNAKE_EMERGING, SNAKE_RETRACTING, SNAKE_DYING, SNAKE_PLUGGED, SNAKE_DEAD }
var state = SNAKE_HIBERNATING
var emergeextent = 0.0
var retractionprogress = 0.0
var timecountdown = 0.0
var emergerate = 0.5*0.1
var retractrate = 1.5*0.1
func resetsnake():
	state = SNAKE_HIBERNATING
	$ReelCyl/ReelSound.stop()
	emergeextent = 0.0
	retractionprogress = 0.0
	timecountdown = randf_range(1, 3)
	print("timecountdown ", timecountdown)
	setsnakepos(1-emergeextent, retractionprogress)
	animmaterial.set_shader_parameter("sickfac", 0.0)
	
func processsnake_startemerge():
	state = SNAKE_EMERGING
	retractionprogress = 0.0
	emergeextent = 0.0
	setsnakepos(1-emergeextent, retractionprogress)
	$ReelCyl/ReelSound.volume_db = -30.0
	$ReelCyl/ReelSound.pitch_scale = 1.0
	$ReelCyl/ReelSound.play()

func processsnake(delta):
	if state == SNAKE_HIBERNATING:
		pass
	elif state == SNAKE_EMERGING:
		emergeextent += delta*emergerate
		if emergeextent >= 1.0:
			emergeextent = 1.0
			state = SNAKE_RETRACTING
		setsnakepos(1-emergeextent, retractionprogress)
	elif state == SNAKE_RETRACTING or state == SNAKE_DYING:
		retractionprogress += retractrate*delta * (0.2 if state == SNAKE_DYING else 1.0)
		$ReelCyl/ReelSound.volume_db = 0
		$ReelCyl/ReelSound.pitch_scale = 2.1-8*(retractionprogress-0.5)*(retractionprogress-0.5)
		if retractionprogress >= 1.0:
			retractionprogress = 0.0 # reset to start
			$ReelCyl/ReelSound.stop()
			state = SNAKE_DEAD if state == SNAKE_DYING else SNAKE_HIBERNATING
			emergeextent = 0.0
			setsnakepos(1-emergeextent, retractionprogress)
			timecountdown = randf_range(1, 3)
		else:
			setsnakepos(1-emergeextent, retractionprogress)

var timecooldown = Time.get_ticks_msec()
func _on_snake_head_area_area_entered(area):
	if not (state == SNAKE_EMERGING or state == SNAKE_RETRACTING):
		return
	if area.checksnakehit($SnakeHeadArea.global_transform.basis.z):
		if state == SNAKE_EMERGING:
			animmaterial.set_shader_parameter("sickfac", 0.25)
			state = SNAKE_RETRACTING
			$SnakeHeadArea/BopSound.pitch_scale = 1.0
			$SnakeHeadArea/BopSound.play()
			timecooldown = Time.get_ticks_msec() + 500
		if state == SNAKE_RETRACTING and timecooldown < Time.get_ticks_msec():
			var tween = get_tree().create_tween()
			tween.tween_method(func(x): animmaterial.set_shader_parameter("sickfac", x), 0.25, 1.0, 2.0)
			state = SNAKE_DYING
			$SnakeHeadArea/BopSound.pitch_scale = 0.5
			$SnakeHeadArea/BopSound.play()
