extends Node3D

var animimage : Image
var animtexture : ImageTexture
var animmaterial = null
var animwidth = 200

func _ready():
	animmaterial = $GSnakeMesh.get_surface_override_material(0)
	var animdata = PackedVector2Array()
	animdata.resize(animwidth)
	for j in range(animwidth):
		var u = j*1.0/animwidth
		animdata.set(j, Vector2(u,sin(u*2) + 1))
	animimage = Image.create_from_data(animwidth, 1, false, Image.FORMAT_RGF, animdata.to_byte_array())
	animtexture = ImageTexture.create_from_image(animimage)
	animmaterial.set_shader_parameter("animtexture", animtexture)
