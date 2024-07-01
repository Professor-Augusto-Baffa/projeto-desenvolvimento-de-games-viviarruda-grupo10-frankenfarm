extends Marker2D

var leg1
var leg2
var Hat
var Hand1
var Hand2
var inventory = preload("res://Resources/Inventory.tres")
var ItemOnHold
var HandOnHold1
var HandOnHold2
var PlayerInventory
var AttackPath


var flipAttack = false
var stepRate = 100
var flip = false
var timeSinceLastStep = 0
var funcTime = 0
var legBounce = 0.2
var offsetAngle = 1.7
var attacking = false
var timeSinceLastAttack = 0
var attackCooldownTime = 0.6

@export var attackRestPos = 75
@export var attackDist = 150

func _ready():
	leg1 = get_node("Leg1")
	leg2 = get_node("Leg2")
	Hat = get_node("Hat")
	Hand1 = get_node("Hand1")
	Hand2 = get_node("Hand2")
	PlayerInventory = get_node("PlayerInventory")
	ItemOnHold = PlayerInventory.get_node("ItemOnHold")
	HandOnHold1 = ItemOnHold.get_node("HandOnHold1")
	HandOnHold2 = ItemOnHold.get_node("HandOnHold2")
	AttackPath = ItemOnHold.get_node("AttackPath")

func _physics_process(delta):
	if Global.playerAlive:
		var direction = Input.get_vector("left", "right", "up", "down")
		var walking = true
		if inventory.item == null:
			attacking = false
			AttackPath.visible = false
		if Input.is_action_pressed("attack") and not attacking and timeSinceLastAttack > attackCooldownTime and ItemOnHold.itemName == "Shovel":
			timeSinceLastAttack = 0
			attacking = true

		Global.playerAttacking = attacking
		
		if direction.x < 0:
			flip = false
		elif direction.x > 0:
			flip = true
		else:
			if direction.y == 0:
				walking = false

		timeSinceLastAttack += delta
		timeSinceLastStep += delta
		funcTime += delta
		leg1.funcTime = funcTime
		leg2.funcTime = funcTime

		body_mov(walking, direction)
		hand_mov(walking)

		if timeSinceLastStep >= 1.0 / stepRate:
			step(delta, flip, walking)
			timeSinceLastStep = 0

func body_mov(walking, direction):
	var _position = global_position
	Hat.rotation = -direction.x * PI / 11
	var wave = Vector2(0, sin(funcTime * 2 + offsetAngle) * legBounce)

	if not walking:
		global_rotation = 0
		_position += wave

	global_position = _position

func item_mov(walking):
	if attacking:
		AttackPath.visible = true
		AttackPath.modulate.a -= 0.05
		ItemOnHold.position.y = 60 
		ItemOnHold.position.y += attackDist/3.0
		if ItemOnHold.position.y >= attackDist:
			ItemOnHold.position.y = attackDist
		if flipAttack:
			AttackPath.flip_h = false
			AttackPath.rotation_degrees = -20
			AttackPath.position = Vector2(-50,-20)
			ItemOnHold.rotation_degrees += 12
			ItemOnHold.position -= Vector2(8,0)
			if ItemOnHold.position.x < -15:
				ItemOnHold.position.x = -15
			if ItemOnHold.rotation_degrees >= 360-attackRestPos:
				ItemOnHold.rotation_degrees = attackRestPos
				attacking = false
				flipAttack = not flipAttack
		else:
			AttackPath.flip_h = true
			AttackPath.rotation_degrees = 20
			AttackPath.position = Vector2(50,-20)
			ItemOnHold.rotation_degrees -= 12
			ItemOnHold.position += Vector2(8, 0)
			if ItemOnHold.position.x > 15:
				ItemOnHold.position.x = 15
			if ItemOnHold.rotation_degrees <= attackRestPos-360:
				ItemOnHold.rotation_degrees = attackRestPos
				attacking = false
				flipAttack = not flipAttack
	else:
		AttackPath.visible = false
		AttackPath.modulate.a = 0.9
		if flipAttack:
			ItemOnHold.position = Vector2(45, 40)
			ItemOnHold.rotation_degrees = attackRestPos
		else:		
			ItemOnHold.position = Vector2(-45, 40)
			ItemOnHold.rotation_degrees = -attackRestPos

		if not walking:
			ItemOnHold.position -= Vector2(0, sin(funcTime * 2 + PI / 3) * 5)
		else:
			ItemOnHold.position -= Vector2(cos(funcTime * 7) * 3, sin(funcTime * 7) * 7)

func aimToTarget():
	var mouse_position = get_global_mouse_position() - PlayerInventory.global_position
	var angle = atan2(mouse_position.y, mouse_position.x)
	PlayerInventory.rotation = angle -PI/2 
	if mouse_position.y < 0:
		PlayerInventory.position = Vector2(0, 20)
	else:
		PlayerInventory.position = Vector2(0, 0)
	if flipAttack:
		PlayerInventory.rotation += PI/5
	else:
		PlayerInventory.rotation -= PI/5

func hand_mov(walking):
	if inventory.item != null:
		item_mov(walking)
		aimToTarget()
		HandOnHold1.visible = true
		HandOnHold2.visible = true
		Hand1.visible = false
		Hand2.visible = false
		if attacking:
			HandOnHold1.position = Vector2(0, 45)
			HandOnHold2.position = Vector2(0, 10)
			HandOnHold2.position.y -= 2
			if HandOnHold2.position.y < -5:
				HandOnHold2.position.y = -5
		else:
			HandOnHold1.position = Vector2(0, 50)
			HandOnHold2.position = Vector2(0, -5)
	else:
		var mouse_position = get_global_mouse_position() - global_position
		var up = false
		if mouse_position.y < 0:
			up = true
		HandOnHold1.visible = false
		HandOnHold2.visible = false
		Hand1.visible = true
		Hand2.visible = true
		Hand1.position = Vector2(0, 40)
		Hand2.position = Vector2(0, 45) #de tras
		if not walking:
			if not flip:
				Hand1.position += Vector2(-40, 0)
				Hand2.position += Vector2(37, 0)
			else:
				Hand1.position += Vector2(40, 0)
				Hand2.position += Vector2(-37, 0)
			if up:
				var auxPosX = Hand1.position.x
				Hand1.position.x = Hand2.position.x
				Hand2.position.x = auxPosX
				if flip:
					Hand2.position.x += 3
				else:
					Hand2.position.x -= 3


			Hand1.position -= Vector2(0, sin(funcTime * 2 + PI / 3) * 4)
			Hand2.position -= Vector2(0, sin(funcTime * 2 + PI / 3) * 4)
		else:
			if flip:
				Hand1.position += Vector2(sin(funcTime * 7) * 50, 0)
				Hand2.position -= Vector2(sin(funcTime * 7) * 50, 0)
			else:
				Hand1.position -= Vector2(sin(funcTime * 7) * 50, 0)
				Hand2.position += Vector2(sin(funcTime * 7) * 50, 0)

func step(delta, _flip, walking):
	leg1.call("step", delta, 1, _flip, walking)
	leg2.call("step", delta, 2, _flip, walking)
