extends Node3D

@export var webrtcroomname : String = "rewindgame"
func _ready():
	if webrtcroomname:
		await get_tree().create_timer(randf()*0.2 + 0.2).timeout
		$NetworkGatewayViewport/Viewport/NetworkGateway.initialstatemqttwebrtc($NetworkGatewayViewport/Viewport/NetworkGateway.NETWORK_OPTIONS_MQTT_WEBRTC.AS_NECESSARY, webrtcroomname, null)
	else:
		$PlayerAvatars.get_child(0).get_node("PlayerFrame").set_process(false)
		$PlayerAvatars.visible = false
	$SnakeMonsters.setusercontrolpanel(%UserControlPanel)
	$SnakeMonsters.edir = "res://level_editor/snakeexrs"
	$SnakeMonsters.loadsnakeexrs()

func _on_start_xr_xr_failed_to_initialize():
	$XROrigin3D/XRSimulator.enabled = true
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

var fadetween = null
func Dset_fade(p_value : float):
	XRToolsFade.set_fade("spawnpoint", Color(0.1, 0.1, 0.1, p_value))
func fadeteleport(trans):
	fadetween = get_tree().create_tween()
	fadetween.tween_method(Dset_fade, 0.0, 1.0, 0.34)
	await fadetween.finished
	$XROrigin3D.transform = trans
	$XROrigin3D/PlayerBody.velocity = Vector3(0,0,0)
	fadetween = get_tree().create_tween()
	fadetween.tween_method(Dset_fade, 1.0, 0.0, 0.34)
	await fadetween.finished
	fadetween = null
	
func _process(delta):
	if $XROrigin3D.position.y < -50 and not fadetween:
		fadeteleport(Transform3D(Basis(), Vector3(0,1,0)))
