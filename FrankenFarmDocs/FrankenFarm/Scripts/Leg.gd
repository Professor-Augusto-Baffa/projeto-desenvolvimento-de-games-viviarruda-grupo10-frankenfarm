extends Marker2D

const MIN_DIST = 10
var Knee
var Foot

var lenUpper = 0
var lenLower = 0

var flip = true
var walking = false

var goalPos = Vector2()
var intPos = Vector2()
var startPos = Vector2()

var stepTime = 0.0
var funcTime = 0.0

@export var stepHeight = 30.0
var stepRate = 0.5
@export var leglength = 50.0
@export var legArch = 20.0
@export var legSpeed = 12.0

func _ready():
	Knee = get_node("Knee")
	Foot = Knee.get_node("Foot")
	lenUpper = Knee.position.x
	lenLower = Foot.position.x

func law_of_cos(a, b, c):
	if 2 * a * b == 0:
		return 0
	return acos((a * a + b * b - c * c) / (2 * a * b))

func sss_calc(side_a, side_b, side_c):
	if side_c >= side_a + side_b:
		return {"A": 0, "B": 0, "C": 0}
	var angle_a = law_of_cos(side_b, side_c, side_a)
	var angle_b = law_of_cos(side_c, side_a, side_b) + PI
	var angle_c = PI - angle_a - angle_b
	if flip:
		angle_a = -angle_a
		angle_b = -angle_b
		angle_c = -angle_c
	return {"A": angle_a, "B": angle_b, "C": angle_c}

func update_ik(targetPos):
	var offset = targetPos - global_position
	var disToTarget = offset.length()
	if disToTarget < MIN_DIST:
		offset = (offset / disToTarget) * MIN_DIST
		disToTarget = MIN_DIST
	var baseR = offset.angle()
	var baseAngles = sss_calc(lenUpper, lenLower, disToTarget)
	global_rotation = baseAngles["A"] + baseR
	Knee.rotation = baseAngles["C"]

func update_foot():
	var _rotation
	var mousePosition = get_global_mouse_position() - global_position
	if flip:
		_rotation = -PI / 2
		if not walking:
			if mousePosition.y < 0:
				_rotation += -PI / 4 - sin(funcTime * 2) * PI / 11
			else:
				_rotation += PI / 10 - sin(funcTime * 2) * PI / 11
	else:
		_rotation = PI - PI / 2
		if not walking:
			if mousePosition.y < 0:
				_rotation -= -PI / 4 - sin(funcTime * 2) * PI / 11
			else:
				_rotation -= PI / 10 - sin(funcTime * 2) * PI / 11
	Foot.rotation = _rotation

func step(_delta, legN, _flip, _walking):
	walking = _walking
	flip = _flip
	var dir
	if flip:
		dir = 1
	else:
		dir = -1
	var PosX
	var PosY
	var footPos = Foot.global_position
	startPos = footPos	
	var legDist
	var _position = position
	if walking:
		legDist = 10
		_position.y = 20
		if legN == 1:
			PosX = cos(dir * funcTime * legSpeed) * legArch
			PosY = sin(dir * funcTime * legSpeed) * stepHeight
		else:
			PosX = cos(dir * funcTime * legSpeed + PI) * legArch
			PosY = sin(dir * funcTime * legSpeed + PI) * stepHeight
	else:
		global_rotation = 0
		legDist = 20
		_position.y = 10
		PosX = 0
		PosY = -sin(funcTime * 2) * 5.0
	if legN == 1:
		position.x = legDist
	elif legN == 2:
		position.x = -legDist
		position = position
	if walking:
		if legN == 1:
			goalPos = Vector2(PosX + legDist, PosY + leglength) + global_position
		elif legN == 2:
			goalPos = Vector2(PosX - legDist, PosY + leglength) + global_position
	else:
		goalPos = Vector2(PosX, PosY + 65) + global_position

func _process(delta):
	stepTime += delta
	var t = stepTime / stepRate
	var targetPos = Vector2()
	if t < 0.5:
		targetPos = startPos.lerp(goalPos, t / 0.5)
	else:
		targetPos = goalPos
	update_ik(targetPos)
	update_foot()
