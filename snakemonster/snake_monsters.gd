extends Node3D

func _ready():
	#GSnakeClass.snakerowstoimage(GSnakeClass.Dmakespiralsnakerows(100, 40)).save_exr("res://snakemonster/gnsake_spiral.exr")
	if false:
		$GSnake0.loadsnakemotionimg("res://snakemonster/gnsake_spiral.exr")
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
			sn.setsnakepos(0.0, 0.0)

func loadintogsnake0(fexr):
	if not has_node("GSnake0"):
		var sn = Csnake.instantiate()
		sn.name = "GSnake0"
		add_child(sn)
		sn.loadsnakemotionimg(fexr)
		sn.setsnakepos(0.0, 0.0)


var snakesplaying = false

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_6:
		for sn in get_children():
			sn.resetsnake()
		snakesplaying = true

func _on_game_playing_button_button_pressed(button):
	for sn in get_children():
		sn.resetsnake()
	snakesplaying = true
	
func _process(delta):
	if snakesplaying:
		for sn in get_children():
			sn.processsnake(delta)

func _on_game_playing_button_button_released(button):
	print("stop snakes playing")
	snakesplaying = false
