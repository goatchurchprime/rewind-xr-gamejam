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
	print(animimage.get_format())
	animtexture = ImageTexture.create_from_image(animimage)
	animmaterial = $GSnakeMesh.get_surface_override_material(0)
	animmaterial.set_shader_parameter("animtexture", animtexture)
