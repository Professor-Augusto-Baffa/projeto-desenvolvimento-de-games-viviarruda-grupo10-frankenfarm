extends Enemy

@onready var BetesteinBody = get_node("BetesteinBody")
@onready var BetesteinArms = []
@onready var BetesteinSprite = BetesteinBody.get_node("BetesteinBody")
@onready var BetesteinLeaves = BetesteinBody.get_node("BetesteinLeaves")

var randomsLeafoffset = {}

func _ready():
	for i in range(0, life):
		BetesteinArms.append(BetesteinBody.get_node("BetesteinArm"+str(i+1)))
	var rng = RandomNumberGenerator.new()
	for i in range(0,3):
		randomsLeafoffset[i] = rng.randf_range(-PI/12, PI/12)

func _physics_process(_delta: float) -> void:
	if alive:
		dir = to_local(nav_agent.get_next_path_position()).normalized()
		if abs(BetesteinArms[0].angleDist) > PI/2:
			velocity = dir*0
		else:
			var speedMult = (life * 0.2) + 0.6
			velocity = dir*speed * speedMult
		move_and_slide()
		body_mov()

func body_mov():
	var rot = -dir.x * (PI/7)+sin(BetesteinArms[0].funcTime*2+PI/5)*PI/12
	var off = -dir*sin(BetesteinArms[0].funcTime*3.5)*30
	BetesteinSprite.rotation = rot
	BetesteinSprite.position = off
	BetesteinLeaves.rotation = rot
	BetesteinLeaves.position = off
	for i in range(0,3):
		BetesteinLeaves.get_child(i).rotation = sin(BetesteinArms[0].funcTime*2+randomsLeafoffset[i]) * PI/13 
		if i == 1:
			BetesteinLeaves.get_child(i).rotation += PI/12
		elif i == 2:
			BetesteinLeaves.get_child(i).rotation -= PI/12


func checkHit():
	if recentlyHit:
		recentlyHit = false
		BetesteinArms[life].hide()
