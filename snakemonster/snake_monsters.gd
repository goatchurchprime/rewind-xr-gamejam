extends Node3D

func _ready():
	#GSnakeClass.snakerowstoimage(GSnakeClass.Dmakespiralsnakerows(100, 40)).save_exr("res://snakemonster/gnsake_spiral.exr")
	$GSnake0.loadsnakemotionimg("res://snakemonster/gnsake_spiral.exr")
	var tween = get_tree().create_tween()
	$GSnake0.animmaterial.set_shader_parameter("texvtime", 0.1)
	tween.tween_method(func (x): $GSnake0.animmaterial.set_shader_parameter("texutime", x), 1.0, 0.0, 5)
	tween.tween_method(func (x): $GSnake0.animmaterial.set_shader_parameter("texutime", x), 0.0, 1.0, 6.0)
