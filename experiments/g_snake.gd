extends Node3D

var animimage : Image
var animtexture : ImageTexture
var animmaterial = null
var animwidth = 1000
var animheight = 400

func _ready():
	animmaterial = $GSnakeMesh.get_surface_override_material(0)
	var animdata = PackedVector3Array()
	animdata.resize(animwidth*animheight)
	for k in range(animheight):
		var kt = k*1.0/animheight
		for j in range(animwidth):
			var u = j*1.0/animwidth
			var tu = u*(45 - kt*30)
			var ur = u*(1+u)*0.2 + kt*0.5
			var p1 = Vector3(u*5,sin(tu)*ur,cos(tu)*ur)
			if u < 0.05:
				p1 *= (u*20)*(u*20)
			animdata.set(j + k*animwidth, p1)

	animimage = Image.create_from_data(animwidth, animheight, false, Image.FORMAT_RGBF, animdata.to_byte_array())
	animtexture = ImageTexture.create_from_image(animimage)
	#animimage.save_png("res://experiments/gnsake.png")
	animmaterial.set_shader_parameter("animtexture", animtexture)

func Dsetsnaketexture(snakerows, imgfile):
	animwidth = len(snakerows[0])
	animheight = len(snakerows)
	var animdata = PackedVector3Array()
	for row in snakerows:
		animdata.append_array(row)
	animimage = Image.create_from_data(animwidth, animheight, false, Image.FORMAT_RGBF, animdata.to_byte_array())
	animtexture = ImageTexture.create_from_image(animimage)
	if imgfile:
		animimage.save_png(imgfile)
	animmaterial.set_shader_parameter("animtexture", animtexture)


func Drunsnake():
	var tween = get_tree().create_tween()
#	tween.tween_method(func (x): animmaterial.set_shader_parameter("texvtime", x), 0.0, 1.0, 1.0)
#	tween.tween_method(func (x): animmaterial.set_shader_parameter("texvtime", x), 1.0, 0.01, 0.5)
	tween.tween_method(func (x): animmaterial.set_shader_parameter("texutime", x), 0.0, 1.0, 1.0)
	tween.tween_method(func (x): animmaterial.set_shader_parameter("texutime", x), 1.0, 0.01, 0.5)

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_V:
#		animmaterial.set_shader_parameter("texvtime", 0.9)
		var tween = get_tree().create_tween()
		tween.tween_method(func (x): animmaterial.set_shader_parameter("texvtime", x), 0.0, 1.0, 2.0)
