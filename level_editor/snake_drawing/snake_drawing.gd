extends Node3D

var lastsegpos = null
var Csnakenode = preload("res://level_editor/snake_drawing/snake_node.tscn")
const snakenodedistance = 0.5
func _on_snake_head_action_pressed(pickable):
	for Ds in $SnakeNodes.get_children():
		$SnakeNodes.remove_child(Ds)
		Ds.queue_free()
	addsegpos($SnakeHead.global_position)
	get_node("../Snake").target = null
	$SnakeNodes.get_child(0).scale = Vector3(2.0,2.0,2.0)
	
func addsegpos(segpos):
	var snakenode = Csnakenode.instantiate()
	$SnakeNodes.add_child(snakenode)
	snakenode.global_position = segpos
	lastsegpos = snakenode.global_position

func _on_snake_head_action_released(pickable):
	lastsegpos = null

func _process(delta):
	if lastsegpos != null:
		var segpos = $SnakeHead.global_position
		if lastsegpos.distance_to(segpos) > snakenodedistance:
			addsegpos(segpos)

		
