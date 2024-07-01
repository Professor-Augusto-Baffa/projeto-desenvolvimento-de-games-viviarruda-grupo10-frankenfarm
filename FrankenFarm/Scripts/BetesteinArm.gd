extends Marker2D

const MIN_DIST = 10
var Elbow
var Hand

var OpenHand 
var ClosedHand

var lenUpper = 0
var lenLower = 0
var angleDist = 0

@export var flip = true
var moving = true

var goalPos = Vector2()
var targetPos = Vector2()

var funcTime = 0.0

@export var movArch = 20.0
@export var movSpeed = 12.0
@export var faseMov = 0.0 
@export var faseAngulo = 0.0 

func _ready():
	Elbow = get_node("BetesteinElbow")
	Hand = Elbow.get_node("BetesteinHand")
	lenUpper = Elbow.position.x
	lenLower = Hand.position.x
	goalPos = global_position
	targetPos = Vector2(0,0)
	OpenHand = Hand.get_node("OpenHand")
	ClosedHand = Hand.get_node("ClosedHand")

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

func update_ik(_targetPos):
	var offset = _targetPos - global_position
	var disToTarget = offset.length()
	if disToTarget < MIN_DIST:
		offset = (offset / disToTarget) * MIN_DIST
		disToTarget = MIN_DIST
	var baseR = offset.angle()
	if is_nan(baseR): 
		baseR = 0
	var baseAngles = sss_calc(lenUpper, lenLower, disToTarget)
	global_rotation = baseAngles["A"] + baseR
	Elbow.rotation = baseAngles["C"]

func update_hand():
	Hand.global_rotation = get_parent().get_parent().dir.angle()

func mov(delta):
	var dir
	if flip:
		dir = 1
	else:
		dir = -1
	var dirToTarget = get_parent().get_parent().dir.rotated(faseAngulo)
	var _offset = sin(dir * funcTime * movSpeed+faseMov) * movArch + 250
	if dir*cos(dir*funcTime * movSpeed+faseMov) < 0:
		OpenHand.visible = false
		ClosedHand.visible = true
	else:
		OpenHand.visible = true
		ClosedHand.visible = false
	var targetDir = targetPos - global_position
	angleDist = dirToTarget.angle() - targetDir.angle() 
	if abs(angleDist) > PI: 
		angleDist = -angleDist/abs(angleDist)*(2*PI - abs(angleDist))
	var angle
	if abs(angleDist) < 0.1: 
		angle = dirToTarget.angle()
		angleDist = 0
	else:
		var angleVel = angleDist/abs(angleDist) * delta * 2
		angle = targetDir.angle() + angleVel
	var newDir = Vector2(cos(angle), sin(angle))
	targetPos = global_position + newDir * _offset
	

func _physics_process(delta):
	funcTime += delta
	update_ik(targetPos)
	update_hand()
	mov(delta)
