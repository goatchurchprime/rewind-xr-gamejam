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
	var Md = 10
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_P:
		var h = $"../XROrigin3D/XRCamera3D".global_basis.z
		links[0].global_position += Vector3(-h.x, 0, -h.z)*Md
		links[0].freeze = true
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_O:
		var h = $"../XROrigin3D/XRCamera3D".global_basis.z
		links[0].global_pospolksition += -Vector3(-h.x, 0, -h.z)*Md

	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_Q:
		$AnimationPlayer.play("snakehead")
		links[0].freeze = false
		links[-1].freeze = true
		links[-1].global_position = $RewindPoint.global_position
		
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_B:
		var tween = get_tree().create_tween()
		tween.tween_property(links[0], "global_position", $RewindPoint.global_position, 2.0)
		#aalinks[0].global_position = $RewindPoint.global_position

#	var g : Animation = $AnimationPlayer.get_animation("snakehead")
#	print(g.get_track_count())
#	print(g.value_track_interpolate(0, 0.1))
#	print(g.value_track_interpolate(0, 3.1))
#	print(g.value_track_interpolate(0, 4.1))

func _physics_process(delta):
	if $AnimationPlayer.is_playing():
		links[-1].global_position = $AnimationPoint.global_position


var links = []
var linkjoins = []
func _ready():
	var linkprev = null
	for i in range(14.03):
		var link = load("res://experiments/link.tscn").instantiate()
		link.position = Vector3(i*gapstep, 0.5, -1)
		link.rotation_degrees.z = 90
		add_child(link)
		links.append(link)
		if i == 0:
			link.freeze = true
		else:
			link.can_sleep = false
		
		var linkjoin = PinJoint3D.new()
		linkjoin.set_param(PinJoint3D.PARAM_BIAS, 0.1)
		if linkprev:
			add_child(linkjoin)
			linkjoin.global_position = Vector3((i-0.5)*gapstep, 0.5, -1)
			linkjoin.node_a = linkprev.get_path() if linkprev else NodePath()
			linkjoin.node_b = link.get_path()
			linkjoins.append(linkjoin)
		linkprev = link
