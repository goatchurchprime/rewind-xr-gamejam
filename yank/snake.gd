class_name Snake
extends Node3D

@export var is_recording = false
@export var speed : float = 5.0
@export var links : int = 20
@export var bendiness_angle : int = 10
@export var target : Node3D

var head : RigidBody3D = null
var bodies : Array[BodyPart]

var frames : Array[State]


class State:
	#var pos_buffer : PackedVector3Array
	var pos_buffer : Array[Vector3]
	var rot_buffer : Array[Quaternion]

func _on_scrub_value_changed(value):
	load_frame(value)

func load_frame(index : int):
	var state = frames[index-1]
	for body in bodies.size():
		bodies[body].freeze = true
		bodies[body].global_position = state.pos_buffer[body]
		bodies[body].quaternion = state.rot_buffer[body]
		

func save_frame():
	var state = State.new()
	for body in bodies:
		state.pos_buffer.append(body.global_position)
		state.rot_buffer.append(body.quaternion)
	frames.append(state)
	
	##TODO remove this later. debug
	%Scrub.max_value = frames.size()
	%Scrub.set_value_no_signal(frames.size())
	%Frame.max_value = frames.size()
	%Frame.set_value_no_signal(frames.size())

func _physics_process(delta):
	if is_recording:
		save_frame()
	
	if head and target:
		var direction = (target.global_position - head.global_position).normalized()
		head.linear_velocity = direction * speed
		
class BodyPart extends RigidBody3D:
	
	var length = 0.5
	var width = 0.1
	var mesh = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	var col = CollisionShape3D.new()
	var capsule_shape = CapsuleShape3D.new()
	
	func _init():
		can_sleep = false
		
		mesh.mesh = capsule_mesh
		capsule_mesh.height = length
		capsule_mesh.radius = width
		mesh.rotation_degrees.x = 90
		add_child(mesh)
		
		col.shape = capsule_shape
		capsule_shape.height = length
		capsule_shape.radius = width
		col.rotation_degrees.x = 90
		physics_material_override = load("res://yank/link_physics_material.tres")
		collision_layer = (1 << 23)
		collision_mask = (1 << 23)
		add_child(col)
	
	func _ready():
		if get_parent() is Snake:
			get_parent().bodies.append(self)

class Joint extends Generic6DOFJoint3D:
	func _init(bendiness):

		set("angular_limit_x/lower_angle", bendiness)
		set("angular_limit_x/upper_angle", -bendiness)
		
		set("angular_limit_z/lower_angle", bendiness)
		set("angular_limit_z/upper_angle", -bendiness)
		
		set("linear_limit_z/lower_distance", -0.1)
		set("linear_limit_z/upper_distance", 0.1)
		
		set("linear_spring_z/enabled", true)
		
func _ready():
	var first_body = BodyPart.new()
	first_body.position.z = 0
	first_body.freeze = false
	add_child(first_body)
	first_body.name = "Head"
	head = first_body  
	var last_body = first_body
	for link in links:
		var body = BodyPart.new()
		body.mass = 5
		body.position.z = -first_body.length * (link + 1)
		add_child(body)
		var joint = Joint.new(bendiness_angle)
		add_child(joint)
		joint.position.z = -first_body.length * (link + 1) + (first_body.length / 2)
		joint.node_a = last_body.get_path()
		joint.node_b = body.get_path()
		last_body = body
	
	last_body.name = "End"
	#lock_linear(last_body, true)
	last_body.freeze = false
	
func _on_record_toggled(toggled_on):
	is_recording = toggled_on


func lock_linear(body, what):
	body.set("axis_lock_linear_x", what)
	body.set("axis_lock_linear_y", what)
	body.set("axis_lock_linear_z", what)
