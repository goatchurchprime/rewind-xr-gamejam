extends Node3D

var usercontrolpanel : Control = null
var scenelist : OptionButton = null

var scenes = {  "llazlo":"res://llazloscene/level_llazz.tscn",
				"lobby":"res://lobbyscene/level_lobby.tscn" }

var exrdirs = { "llazlo":"res://level_editor/snakeexrs",
				"lobby":"res://lobbyscene/snakeexrs" }

func setusercontrolpanel(lusercontrolpanel):
	usercontrolpanel = lusercontrolpanel
	scenelist = usercontrolpanel.get_node("VBox/HBox2/SceneChoice")
	scenelist.item_selected.connect(sceneselected)

func Dset_fade(p_value : float):
	XRToolsFade.set_fade("spawnpoint", Color(0.1, 0.1, 0.1, p_value))

func sceneselected(i):
	var scenename = scenelist.get_item_text(i)
	print("Scene selected ", scenename)
	var sceneres = scenes[scenename]

	var fadetween = get_tree().create_tween()
	fadetween.tween_method(Dset_fade, 0.0, 1.0, 0.34)
	await fadetween.finished

	if get_child_count() >= 1:
		var x = get_child(-1)
		remove_child(x)
		x.queue_free()
	add_child(load(sceneres).instantiate())
	var snakemonsters = get_node("../SnakeMonsters")
	snakemonsters.edir = exrdirs[scenename]
	snakemonsters.loadsnakeexrs()

	get_node("../XROrigin3D").transform = Transform3D()
	get_node("../XROrigin3D/PlayerBody").velocity = Vector3(0,0,0)
	fadetween = get_tree().create_tween()
	fadetween.tween_method(Dset_fade, 1.0, 0.0, 0.34)
	await fadetween.finished
	fadetween = null
