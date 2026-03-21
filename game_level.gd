extends Node3D

var usercontrolpanel : Control = null
var scenelist : OptionButton = null

var scenes = {  "llazlo":"res://llazloscene/level_llazz.tscn",
				"lobby":"res://lobbyscene/level_lobby.tscn",
				"tavi":"res://assets/Scenes/Definitive/Scenes/level.tscn" }


var exrdirs = { "llazlo":"res://llazloscene/snakeexrs",
				"lobby":"res://lobbyscene/snakeexrs",
				"tavi":"res://level_editor/snakeexrs" }

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

	var snakemonsters = get_node("../SnakeMonsters")
	hideendlevelnote()
	if get_child_count() >= 1:
		var x = get_child(-1)
		if x.name.begins_with("Level"):
			x.remove_child(x)
			x.queue_free()

	var scn : Node = load(sceneres).instantiate()
	add_child(scn)
	var nodestack = [ scn ]
	while nodestack:
		var nd = nodestack.pop_back()
		if is_instance_of(nd, StaticBody3D):
			nd.collision_layer = get_node("../World/Floor").collision_layer
		nodestack.append_array(nd.get_children())
		if is_instance_of(nd, SpotLight3D) and nd.get_name() == "SpotLight3D":
			nd.spot_angle = 20
			nd.spot_attenuation = 0.6
			nd.light_color = Color(1,1,0.5)
	
	snakemonsters.edir = exrdirs[scenename]
	snakemonsters.loadsnakeexrs()
	if snakemonsters.snakesplaying:
		snakemonsters.playsnakes(true)

	get_node("../XROrigin3D").transform = Transform3D()
	get_node("../XROrigin3D/PlayerBody").velocity = Vector3(0,0,0)
	fadetween = get_tree().create_tween()
	fadetween.tween_method(Dset_fade, 1.0, 0.0, 0.34)
	await fadetween.finished
	fadetween = null

func showendlevelnote(nplugged, ndead):
	if not $EndLevelNote.visible:
		$EndLevelNote.visible = true
		$EndLevelNote/Label3D.text = "Level Complete\nPlugged: %d  stopped: %d" % [nplugged, ndead]
		$EndLevelNote/InteractableAreaButtonNext.monitoring = true
		$EndLevelNote/InteractableAreaButtonAgain.monitoring = true

func hideendlevelnote():
	$EndLevelNote.visible = false
	$EndLevelNote/Label3D.text = "not shown"
	$EndLevelNote/InteractableAreaButtonNext.monitoring = false
	$EndLevelNote/InteractableAreaButtonAgain.monitoring = false


func _on_interactable_area_button_next_button_pressed(button):
	scenelist.select((scenelist.selected + 1) % scenelist.item_count)
	print("selected ", scenelist.selected, " ",  scenelist.item_count)
	scenelist.item_selected.emit(scenelist.selected)
	$EndLevelNote/InteractableAreaButtonNext/MeshInstance3D.rumble()
	$EndLevelNote/InteractableAreaButtonAgain/MeshInstance3D.rumble()

func _on_interactable_area_button_stay_2_button_pressed(button):
	scenelist.item_selected.emit(scenelist.selected)
	$EndLevelNote/InteractableAreaButtonNext/MeshInstance3D.rumble()
	$EndLevelNote/InteractableAreaButtonAgain/MeshInstance3D.rumble()
