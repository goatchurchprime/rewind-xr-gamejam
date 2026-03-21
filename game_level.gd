extends Node3D

var usercontrolpanel : Control = null
var scenelist : OptionButton = null

var scenes = {  "llazlo":"res://llazloscene/level_llazz.tscn",
				"lobby":"res://lobbyscene/level_lobby.tscn" }

var exrdirs = { "llazlo":"res://level_editor/snakeexrs",
				"lobby":"res://lobbyscene/snakeexrs" }

func sceneselected(i):
	var scenename = scenelist.get_item_text(i)
	print("Scene selected ", scenename)
	var sceneres = scenes[scenename]
	if get_child_count() == 1:
		var x = get_child(0)
		remove_child(x)
		x.queue_free()
	add_child(load(sceneres).instantiate())
	var snakemonsters = get_node("../SnakeMonsters")
	snakemonsters.edir = exrdirs[scenename]
	snakemonsters.loadsnakeexrs()

func setusercontrolpanel(lusercontrolpanel):
	usercontrolpanel = lusercontrolpanel
	scenelist = usercontrolpanel.get_node("VBox/HBox2/SceneChoice")
	scenelist.item_selected.connect(sceneselected)
