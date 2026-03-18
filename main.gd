extends Node3D

@export var webrtcroomname : String = "rewindgame"
func _ready():
	if webrtcroomname:
		await get_tree().create_timer(randf()*0.2 + 0.2).timeout
		$NetworkGatewayViewport/Viewport/NetworkGateway.initialstatemqttwebrtc($NetworkGatewayViewport/Viewport/NetworkGateway.NETWORK_OPTIONS_MQTT_WEBRTC.AS_NECESSARY, webrtcroomname, null)
		

func _on_start_xr_xr_failed_to_initialize():
	$XROrigin3D/XRSimulator.enabled = true
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

var fadetween = null
func Dset_fade(p_value : float):
	XRToolsFade.set_fade("spawnpoint", Color(0.3, 0, 0, p_value))

func _process(delta):
	if $XROrigin3D.position.y < -50 and not fadetween:
		fadetween = get_tree().create_tween()
		fadetween.tween_method(Dset_fade, 0.0, 1.0, 0.34)
		await fadetween.finished
		$XROrigin3D.position = Vector3(0,1,0)
		$XROrigin3D/PlayerBody.velocity = Vector3(0,0,0)
		fadetween = get_tree().create_tween()
		fadetween.tween_method(Dset_fade, 1.0, 0.0, 0.34)
		await fadetween.finished
		fadetween = null
		


var snakerows = null
func _on_snake_head_target_action_pressed(pickable):
	print("target pressed")
	snakerows = [ ]
	while snakerows != null:
		var row : = PackedVector3Array()
		row.resize(len($Snake.bodies))
		for i in range(len($Snake.bodies)):
			row[i] = $Snake.bodies[i].global_position
		row.reverse()
		snakerows.append(row)
		await get_tree().create_timer(0.2).timeout

func _on_snake_head_target_action_released(pickable):
	print("target released ", len(snakerows))
	$GSnake.Dsetsnaketexture(snakerows)
	snakerows = null
	$GSnake.global_transform = Transform3D()

var tweensnakeout = null
func _on_xr_controller_3d_left_button_pressed(name):
	if name == "trigger_click":
		$GSnake.animmaterial.set_shader_parameter("texvtime", 0)
		tweensnakeout = get_tree().create_tween()
		tweensnakeout.tween_method(func (x): $GSnake.animmaterial.set_shader_parameter("texutime", x), 1.0, 0.0, 4.0)

var tweensnakerewind = null
func _on_xr_controller_3d_left_button_released(name):
	if name == "trigger_click" and tweensnakeout:
		if tweensnakeout.is_running():
			print("Snake reached destination")
		tweensnakeout.kill()
		tweensnakeout = null
		tweensnakerewind = get_tree().create_tween()
		tweensnakerewind.tween_method(func (x): $GSnake.animmaterial.set_shader_parameter("texvtime", x), 0.0, 1.0, 0.4)
		var u0 = $GSnake.animmaterial.get_shader_parameter("texutime")
		tweensnakerewind.tween_method(func (x): $GSnake.animmaterial.set_shader_parameter("texutime", x), u0, 1.0, 0.4)
