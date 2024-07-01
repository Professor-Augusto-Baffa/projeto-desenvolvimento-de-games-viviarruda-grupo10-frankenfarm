extends CharacterBody2D

const Speed = 520.0
const Accel = 50.0

var enemyInRange = false
var alive = true

@export var maxLife = 10
@onready var life = maxLife
@onready var healthBar = $HealthBar
var damageCooldown = true
var canRegen = true
var canPlant = false

@export var tile_map : TileMap

func _physics_process(_delta):
	checkPlayerPlant()
	Global.playerCurrLife = life
	enemyAttackCheck()
	updateHealth()
	if alive and life <= 0:
		alive = false
		life = 0
		Global.playerAlive = false
		die()

	if alive:
		var direction = Input.get_vector("left", "right", "up", "down")

		velocity.x = move_toward(velocity.x, Speed * direction.x, Accel)
		velocity.y = move_toward(velocity.y, Speed * direction.y, Accel)

		move_and_slide()


func _on_player_hitbox_body_exited(body:Node2D):
	if body.has_method("enemy"):
		enemyInRange = false 

func _on_player_hitbox_body_entered(body:Node2D):
	if body.has_method("enemy"):
		if body.life > 0:
			enemyInRange = true

func enemyAttackCheck():
	if enemyInRange and damageCooldown:
		life -= 1
		Global.damageGiven = true
		damageCooldown = false
		$DamageCooldown.start()
		canRegen = false
		$CanRegenTimer.start()

func die():
	pass

func player():
	pass

func checkPlayerPlant():
	var tile_player_pos: Vector2i = tile_map.local_to_map(global_position/6.25)
	var tile_data : TileData = tile_map.get_cell_tile_data(0,tile_player_pos)
	if tile_data:
		canPlant = tile_data.get_custom_data("dirt")
		if canPlant:
			Global.playerCanPlant = true
		else:
			Global.playerCanPlant = false
	else:
		print("no tile_data")

func updateHealth():
	healthBar.value = life 
	if life >= maxLife:
		healthBar.visible = false
	else:
		healthBar.visible = true

func _on_regen_timer_timeout():
	if life <= 0:
		life = 0
	elif canRegen and life < maxLife:
		life += 1
		if life > maxLife:
			life = maxLife

func _on_damage_cooldown_timeout():
	damageCooldown = true 

func _on_can_regen_timer_timeout():
	canRegen = true
