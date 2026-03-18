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
		rodB.freeze = false

func _on_snake_head_action_pressed(pickable):
	if lastsegpos == null and $ReelPoint.visible:
		if snakepulling != 0:
			$ReelPoint.visible = false
		else:
			snakepulling = 1

	elif lastsegpos == null:
		clearsnake()
		lastsegpos = $SnakeHead.global_position
		$ReelPoint.global_position = lastsegpos
		$ReelPoint.visible = true
		get_node("../Snake").target = null
		$SnakeHead/ActiveMesh.visible = true

	else:
		lastsegpos = null
		$SnakeHead/ActiveMesh.visible = false
		var firstlastleng = $SnakeHead.global_position.distance_to($ReelPoint.global_position)
		if firstlastleng > snakenodedistance:
			createsnakejoints()
		else:
			clearsnake()
			$ReelPoint.visible = false

"sdfsf"
func _on_snake_head_grabbed(pickable, by):
	polyplayback.play_stream(grab_sound)

func _on_snake_head_released(pickable, by):
	polyplayback.play_stream(release_sound)
	
func _on_snake_head_action_released(pickable):
	pass

var Csnakerod = preload("res://level_editor/snake_drawing/snake_rod.tscn")
func _process(delta):
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

const rodvelocity = 1.0
const rodangvel = deg_to_rad(140)
func _physics_process(delta):
	if snakepulling == 0:
		return
	if $SnakeNodes.get_child_count() == 0:
		snakepulling = 0
		$ReelPoint.visible = false
		return
	var sn0 = $SnakeNodes.get_child(0)
	sn0.freeze = true
	
	if snakepulling == 1 or snakepulling == 3:
		var sn0end = sn0.global_transform*Vector3(0,0,-snakenodedistance*0.5 if snakepulling == 1 else snakenodedistance*0.5)
		var vecm0 : Vector3 = $ReelPoint.global_position - sn0end
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
					snakepulling = 0
		else:
			sn0.global_position += vecm0*(drod/vecm0len)
	elif snakepulling == 2:
		var rotdiff = acos($ReelPoint.global_transform.basis.z.dot(sn0.global_transform.basis.z))
		var rotperp = $ReelPoint.global_transform.basis.z.cross(sn0.global_transform.basis.z).normalized()
		var drot = rodangvel*delta
		sn0.global_transform.basis = sn0.global_transform.basis.rotated(rotperp, -min(rotdiff, drot))
		var sn0end = sn0.global_transform*Vector3(0,0,-snakenodedistance*0.5)
		var vecm0 : Vector3 = $ReelPoint.global_position - sn0end
		sn0.global_position += vecm0

		if rotdiff <= drot:
			snakepulling = 3
		
