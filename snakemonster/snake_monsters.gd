extends Node3D

var snakesplaying = false
var usercontrolpanel : Control = null
var snakelist : OptionButton = null
var playsnakesbutton : CheckButton = null
var makesnakebutton : Button = null
var deletesnakebutton : Button = null
var playsnakesfastbutton : CheckButton = null

var Csnake = load("res://snakemonster/gsnake.tscn")
var edir = "res://level_editor/snakeexrs"
var fromresourceloader = true
@onready var SnakeDrawing = get_node("../SnakeDrawing")

func loadsnakeexrs():
	for sn in get_children():
		remove_child(sn)
		sn.queue_free()
	for fn in DirAccess.open(edir).get_files():
		if fn.get_extension() == "exr":
			var sn = Csnake.instantiate()
			sn.name = fn.get_basename()
			add_child(sn)
			sn.loadsnakemotionimg(edir.path_join(fn), fromresourceloader)
			sn.setsnakepos(0.0, 0.0)
	updatesnakelist()


func animatesnake():
	pass

func playsnakes(toggled):
	snakesplaying = toggled
	if toggled:
		var fac = 1.0 if playsnakesfastbutton.button_pressed else 0.1
		for sn in get_children():
			sn.resetsnake()
			sn.emergerate = 0.5*fac
			sn.retractrate = 1.5*fac
	else:
		for sn in get_children():
			sn.get_node("ReelCyl/ReelSound").stop()

func makesnake():
	SnakeDrawing.makesnake()

func setusercontrolpanel(lusercontrolpanel):
	usercontrolpanel = lusercontrolpanel
	print(lusercontrolpanel.get_path())
	snakelist = usercontrolpanel.get_node("VBox/SnakeEntities")
	usercontrolpanel.get_node("VBox/HBox/AnimateSnake").connect("pressed", animatesnake)
	playsnakesbutton = usercontrolpanel.get_node("VBox/HBox2/PlaySnakes")
	playsnakesbutton.connect("toggled", playsnakes)
	makesnakebutton = usercontrolpanel.get_node("VBox/HBox/MakeSnake")
	makesnakebutton.connect("pressed", makesnake)
	deletesnakebutton = usercontrolpanel.get_node("VBox/HBox/DeleteSnake")
	deletesnakebutton.connect("pressed", deletesnake)
	playsnakesfastbutton = usercontrolpanel.get_node("VBox/HBox2/PlayFast")
	updatesnakelist()

func newsnakeimage(lsnakeimage : Image):
	var fn
	for i in range(100):
		fn = edir.path_join("gnsake%d.exr" % i)
		if not FileAccess.file_exists(fn):
			break
	lsnakeimage.save_exr(fn)
	fromresourceloader = false  # now we have unimported resources
	loadsnakeexrs()

func deletesnake():
	var fn = edir.path_join(snakelist.get_item_text(snakelist.selected)+".exr")
	print("Deleting ", fn)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(fn))
	fromresourceloader = false  # now we have unimported resources
	loadsnakeexrs()

func updatesnakelist():
	if snakelist:
		snakelist.clear()
		for sn in get_children():
			snakelist.add_item(sn.get_name())

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_P:
			playsnakesbutton.button_pressed = not playsnakesbutton.button_pressed
		if event.keycode == KEY_O:
			makesnakebutton.pressed.emit()
		if event.keycode == KEY_L:
			snakelist.select((snakelist.selected+1) % snakelist.item_count) 
		if event.keycode == KEY_K:
			deletesnakebutton.pressed.emit()

func _process(delta):
	if snakesplaying:
		for sn in get_children():
			sn.processsnake(delta)
