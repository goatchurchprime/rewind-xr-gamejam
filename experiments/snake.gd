extends Node3D

var Dx = 3.0
var gapstep = 0.55
func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_K:
		print(links[0].global_position.x)
		links[0].global_rotation.z += 0.2
		print(links[0].global_positiopn.x)
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_L:
		print(links[0].global_position.x)
		links[0].global_rotation.y += 0.2
		print(links[0].global_position.x)
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_P:
		var h = $"../XROrigin3D/XRCamera3D".global_basis.z
		links[0].global_position += Vector3(-h.x*0.5, 0, -h.z*0.5)
		links[0].freeze = true
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_O:
		var h = $"../XROrigin3D/XRCamera3D".global_basis.z
		links[0].global_position += -Vector3(-h.x*0.5, 0, -h.z*0.5)
		
var links = []
var linkjoins = []
func _ready():
	var linkprev = null
	for i in range(13):
		var link = load("res://experiments/link.tscn").instantiate()
		link.position = Vector3(i*gapstep-2, 0.5, -1)
		link.rotation_degrees.z = 90
		add_child(link)
		links.append(link)
		if i == 0:
			link.freeze = true
		else:
			link.can_sleep = false
		
		var linkjoin
		if false:
			linkjoin = load("res://experiments/link_join.tscn").instantiate()
			linkjoin.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT,i*0.4)
			linkjoin.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT,i*0.4)
		else:
			linkjoin = PinJoint3D.new()
			linkjoin.set_param(PinJoint3D.PARAM_BIAS, 0.01)
			#linkjoin = load("res://experiments/link_join2.tscn").instantiate()
		if linkprev:
			add_child(linkjoin)
			linkjoin.global_position = Vector3((i-0.5)*gapstep-2, 0.5, -1)
			linkjoin.node_a = linkprev.get_path() if linkprev else NodePath()
			linkjoin.node_b = link.get_path()
			linkjoins.append(linkjoin)
		linkprev = link
