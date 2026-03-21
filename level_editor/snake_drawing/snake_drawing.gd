extends Node3D

@export var grab_sound : AudioStream
@export var release_sound : AudioStream
@export var mark_sound : AudioStream

@onready var polyplayback : AudioStreamPlaybackPolyphonic = $SnakeHead/AudioStreamPlayer3D.get_stream_playback()
var lastsegpos = null
var Csnakenode = preload("res://level_editor/snake_drawing/snake_node.tscn")
var Csnakejoint = preload("res://level_editor/snake_drawing/snake_6dof_joint.tscn")
const snakenodedistance = 0.5

var snakepulling = 0
func clearsnake():
	for Ds in $SnakeNodes.get_children():
		$SnakeNodes.remove_child(Ds)
		Ds.queue_free()
	for Ds in $SnakeJoints.get_children():
		$SnakeJoints.remove_child(Ds)
		Ds.queue_free()
	snakepulling = 0
	
func createsnakejoints():
	for i in range(1, $SnakeNodes.get_child_count()):
		var rodA = $SnakeNodes.get_child(i-1)
		var rodB = $SnakeNodes.get_child(i)
		var joint : Generic6DOFJoint3D = Csnakejoint.instantiate()
		#var joint : Joint3D = PinJoint3D.new()
		$SnakeJoints.add_child(joint)
		joint.global_position = rodA.global_transform*Vector3(0,0,snakenodedistance*0.5)
		joint.look_at(rodA.global_position)
		joint.node_a = rodA.get_path()
		joint.node_b = rodB.get_path()

func _on_snake_head_action_pressed(pickable):
	if lastsegpos == null and $ReelBox.visible:
		snakepulling = 0
		$ReelBox.visible = false
		$ReelBox.enabled = false

	elif lastsegpos == null:
		clearsnake()
		lastsegpos = $SnakeHead.global_position
		var headrodtrans = Transform3D(Basis(), lastsegpos)
		$ReelBox.global_transform = headrodtrans*$ReelBox/ReelPoint.transform.inverse()
		print("set reelbox trans ", $ReelBox.global_transform)
		$ReelBox.visible = true
		$ReelBox.enabled = true
		print("Reel box ", $ReelBox.global_transform)
		$SnakeHead/ActiveMesh.visible = true

	else:
		lastsegpos = null
		$SnakeHead/ActiveMesh.visible = false
		clearsnake()
		$ReelBox.visible = false
		$ReelBox.enabled = false

"sdfsf"
func _on_snake_head_grabbed(pickable, by):
	polyplayback.play_stream(grab_sound)

func _on_snake_head_released(pickable, by):
	polyplayback.play_stream(release_sound)
	
func _on_snake_head_action_released(pickable):
	pass

var Csnakerod = preload("res://level_editor/snake_drawing/snake_rod.tscn")
func _process(delta):
	#print($ReelBox.get_global_rotation_degrees())
	if lastsegpos != null:
		var segpos = $SnakeHead.global_position
		if lastsegpos.distance_to(segpos) > snakenodedistance:
			var snakerod : RigidBody3D = Csnakerod.instantiate()
			snakerod.freeze = true
			snakerod.name = "SnakeRod%d" % $SnakeNodes.get_child_count()
			$SnakeNodes.add_child(snakerod)
			snakerod.global_position = (lastsegpos + segpos)*0.5
			snakerod.look_at(lastsegpos)
			polyplayback.play_stream(mark_sound)
			lastsegpos = segpos
		
			if $SnakeNodes.get_child_count() == 1:
				var p00 = $ReelBox/ReelPoint.global_position
				var p01f = Vector3(segpos.x, p00.y, segpos.z)
				$ReelDirectionMarker3D.look_at_from_position(p00, p00 - (p01f - p00))
				$ReelBox.global_transform = $ReelDirectionMarker3D.global_transform*$ReelBox/ReelPoint.transform.inverse()
				print("set reelbox trans1 ", $ReelBox.global_transform)


const rodvelocity = 1.0
const rodangvel = deg_to_rad(140)

var snakerows = [ ]
var snakerowwidth = 100
var snakefulllength = 0.0
var snakeupdatetimer = 0.0
var snakeupdatetimeframe = 0.25

func slalength(sla):
	var res = 0.0
	for i in range(1, len(sla)):
		res += sla[i-1].distance_to(sla[i])
	return res
	
func startsnakepulling():
	for i in range(1, $SnakeNodes.get_child_count()):
		var rodB = $SnakeNodes.get_child(i)
		rodB.freeze = false
		rodB.linear_velocity = (-rodB.global_transform.basis.z + Vector3(0,1.5,0))*(0.5 + i/$SnakeNodes.get_child_count())

	snakepulling = 1
	var sla = snakelocationarray()
	snakeupdatetimer = 0.0
	snakefulllength = slalength(sla)
	print("start snake pulling length ", snakefulllength)
	snakerowwidth = clampi(int(snakefulllength/0.33), 5, 200)
	var srow = calcsnakerow(sla)
	snakerows = [ srow ]

	if false:  # of calcsnakerow
		var Dsnakerow = get_node_or_null("DSnakeRow")
		if Dsnakerow:
			remove_child(Dsnakerow)
			Dsnakerow.queue_free()
		Dsnakerow = Node3D.new()
		Dsnakerow.name = "DSnakeRow"
		add_child(Dsnakerow)
		for p in srow:
			var m = MeshInstance3D.new()
			m.mesh = BoxMesh.new()
			m.scale *= 0.3
			Dsnakerow.add_child(m)
			m.global_position = p

func calcsnakerow(sla):
	var i = len(sla) - 2
	var lam = 1.0
	var lstep = snakefulllength/(snakerowwidth - 1)
	var srow = [ sla[-1] ]
	var lstepremain = lstep
	while len(srow) < snakerowwidth and i >= 0:
		var seglen = sla[i].distance_to(sla[i+1])
		var lamstep = lstepremain/seglen
		if lam < lamstep:
			lstepremain -= lam*seglen
			i -= 1
			lam = 1.0
		else:
			lam -= lamstep
			srow.append(lerp(sla[i], sla[i+1], lam))
			lstepremain = lstep
	while len(srow) < snakerowwidth:
		srow.append(sla[0])
	srow.reverse()
	return srow

func _physics_process(delta):
	if snakepulling == 0:
		return
	if $SnakeNodes.get_child_count() == 0:
		snakepulling = 0
		$ReelBox.visible = false
		$ReelBox.enabled = false
		return

	advancesnakepulling(delta)
	if snakerows:
		snakeupdatetimer += delta
		if snakeupdatetimer >= snakeupdatetimeframe:
			var sla = snakelocationarray()
			var srow = calcsnakerow(sla)
			snakerows.append(srow)
			snakeupdatetimer -= snakeupdatetimeframe

func snakelocationarray():
	var res = [ $ReelBox/ReelPoint.global_transform.origin ]
	for i in range($SnakeNodes.get_child_count()):
		var sni = $SnakeNodes.get_child(i)
		var sniendnear = sni.global_transform*Vector3(0,0,-snakenodedistance*0.5)
		var sniendfar = sni.global_transform*Vector3(0,0,snakenodedistance*0.5)
		if i != 0 and not res[-1].is_equal_approx(sniendnear):
			res.append(sniendnear)
		if not res[-1].is_equal_approx(sniendfar):
			res.append(sniendfar)
	return res

func advancesnakepulling(delta):
	var sn0 = $SnakeNodes.get_child(0)
	sn0.freeze = true
	var rt = $ReelBox/ReelPoint.global_transform
	if snakepulling == 1 or snakepulling == 3:
		var sn0end = sn0.global_transform*Vector3(0,0,-snakenodedistance*0.5 if snakepulling == 1 else snakenodedistance*0.5)
		var vecm0 : Vector3 = rt.origin - sn0end
		var vecm0len = vecm0.length()
		var drod = rodvelocity*delta
		if vecm0len <= drod:
			sn0.global_position += vecm0
			if snakepulling == 1:
				snakepulling = 2
			else:
				$SnakeNodes.remove_child(sn0)
				sn0.queue_free()
				if $SnakeNodes.get_child_count() != 0:
					snakepulling = 1
				else:
					if snakerows:
						get_node("../SnakeMonsters").newsnakeimage(GSnakeClass.snakerowstoimage(snakerows))
						snakerows = [ ]
					snakepulling = 0
		else:
			sn0.global_position += vecm0*(drod/vecm0len)
	elif snakepulling == 2:
		var rotdiff = acos(rt.basis.z.dot(sn0.global_transform.basis.z))
		var rotperp = rt.basis.z.cross(sn0.global_transform.basis.z).normalized()
		var drot = rodangvel*delta
		sn0.global_transform.basis = sn0.global_transform.basis.rotated(rotperp, -min(rotdiff, drot))
		var sn0end = sn0.global_transform*Vector3(0,0,-snakenodedistance*0.5)
		var vecm0 : Vector3 = rt.origin - sn0end
		sn0.global_position += vecm0
		if rotdiff <= drot:
			snakepulling = 3

func makesnake():
	if $ReelBox.visible and snakepulling == 0 and $SnakeNodes.get_child_count() != 0:
		if lastsegpos != null: 
			lastsegpos = null
			$SnakeHead/ActiveMesh.visible = false
			var firstlastleng = $SnakeHead.global_position.distance_to($ReelBox/ReelPoint.global_position)
			createsnakejoints()
		startsnakepulling()
