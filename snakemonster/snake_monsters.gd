extends Node3D

func _ready():
	#GSnakeClass.snakerowstoimage(GSnakeClass.Dmakespiralsnakerows(100, 40)).save_exr("res://snakemonster/gnsake_spiral.exr")
	if false:
		$GSnake0.loadsnakemotionimg("res://snakemonster/gnsake_spiral.exr")
		var tween = get_tree().create_tween()
		$GSnake0.animmaterial.set_shader_parameter("texvtime", 0.1)
		tween.tween_method(func (x): $GSnake0.animmaterial.set_shader_parameter("texutime", x), 1.0, 0.0, 5)
		tween.tween_method(func (x): $GSnake0.animmaterial.set_shader_parameter("texutime", x), 0.0, 1.0, 6.0)
	else:
		loadsnakeexrs("res://level_editor/snakeexrs")

var Csnake = load("res://snakemonster/gsnake.tscn")
func loadsnakeexrs(edir):
	print(ResourceLoader.list_directory(edir))
	for sn in get_children():
		remove_child(sn)
		sn.queue_free()
	for fn in ResourceLoader.list_directory(edir):
		if fn.get_extension() == "exr":
			var sn = Csnake.instantiate()
			sn.name = fn.get_basename()
			add_child(sn)
			sn.loadsnakemotionimg(edir.path_join(fn))
			sn.animmaterial.set_shader_parameter("texutime", 0.0)
			sn.animmaterial.set_shader_parameter("texvtime", 0.0)

func loadintogsnake0(fexr):
	if not has_node("GSnake0"):
		var sn = Csnake.instantiate()
		sn.name = "GSnake0"
		add_child(sn)
		sn.loadsnakemotionimg(fexr)
		sn.animmaterial.set_shader_parameter("texutime", 0.0)
		sn.animmaterial.set_shader_parameter("texvtime", 0.0)
