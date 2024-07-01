extends CanvasLayer

@onready var nightColor = $NightColor
@onready var nightShader = $NightShader
var shader_material
var targetNoise
var targetGhost
var targetBrightness
var currNoise = 0
var currBrightness = 0
var transitioning = false
var current_time = 0.0
var duration = 2.0
var targetR
var targetG
var targetB

func _ready():
	targetR = nightColor.color.r * 255 as int
	targetG = nightColor.color.g * 255 as int
	targetB = nightColor.color.b * 255 as int
	nightColor.color = Color(1, 1, 1)
	shader_material = nightShader.material as ShaderMaterial
	checkNightTime()
	shader_material.set_shader_parameter("crt_white_noise", targetNoise)
	shader_material.set_shader_parameter("crt_brightness", targetBrightness)
	currNoise = targetNoise
	currBrightness = currBrightness
	

func _physics_process(delta):
	if not transitioning:
		var noiseMod = 1.0 + (1.0-Global.playerCurrLife/10.0)*2.0
		shader_material.set_shader_parameter("crt_white_noise", currNoise*noiseMod)
		if not Global.playerAlive:
			shader_material.set_shader_parameter("crt_white_noise", 1.0)
			nightColor.color = Color(1, 0.6, 1)
		
		if Global.nightTime:
			$TurnToNight.visible = false
			if Global.numberOfSpawners <= 0:
				Global.nightTime = false
				transitioning = true
				Global.transition = true
				$Transition.start()
				$TurnToNight.visible = true

	checkNightTime()
	updateFilter(delta)

func updateFilter(delta):
	if transitioning:
		current_time += delta
		var t = clamp(current_time / duration, 0.0, 1.0)
		if Global.nightTime:
			var r = lerp(255, targetR, t)/255.0
			var g = lerp(255, targetG, t)/255.0
			var b = lerp(255, targetB, t)/255.0
			nightColor.color = Color(r,g,b)

			currNoise += delta
			if currNoise >= targetNoise:
				shader_material.set_shader_parameter("crt_white_noise", currNoise)
			currBrightness += delta
			if currBrightness >= targetBrightness:
				shader_material.set_shader_parameter("crt_brightness", currBrightness)


		else:
			var r = lerp(targetR, 255, t)/255.0
			var g = lerp(targetG, 255, t)/255.0
			var b = lerp(targetB, 255, t)/255.0
			nightColor.color = Color(r,g,b)

			currNoise -= delta
			if currNoise <= targetNoise:
				shader_material.set_shader_parameter("crt_white_noise", currNoise)
			currBrightness -= delta
			if currBrightness <= targetBrightness:
				shader_material.set_shader_parameter("crt_brightness", currBrightness)

func checkNightTime():
	if shader_material:
		if Global.nightTime:
			targetNoise = 0.2
			targetBrightness = 0.76
		else:
			targetNoise = 0.01
			targetBrightness = 0.27

func _on_turn_to_night_pressed():
	if not transitioning and Global.numberOfSpawners > 0:
		Global.nightTime = !Global.nightTime
		transitioning = true
		Global.transition = true
		$Transition.start()


func _on_transition_timeout():
	transitioning = false
	current_time = 0
	if Global.nightTime:
		nightColor.color = Color(targetR/255.0, targetG/255.0, targetB/255.0)
	else:
		nightColor.color = Color(1,1,1)
	shader_material.set_shader_parameter("crt_white_noise", targetNoise)
	shader_material.set_shader_parameter("crt_brightness", targetBrightness)
	currNoise = targetNoise
	currBrightness = currBrightness