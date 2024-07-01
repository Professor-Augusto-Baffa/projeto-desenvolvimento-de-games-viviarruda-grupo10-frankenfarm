class_name Enemy extends CharacterBody2D

@export var speed = 100

var playerAttackInRange = false
var alive = true
var damageCooldown = true
var recentlyHit = false

@export var maxLife = 3
@onready var life = maxLife

var player

var dir = Vector2(0,0)

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _physics_process(_delta: float) -> void:
	dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir*speed
	move_and_slide()

func _process(_delta):
	playerAttackCheck()
	if life <= 0:
		alive = false
		life = 0
	checkHit()
	die()

func die():
	if not alive:
		queue_free()

func makepath() -> void:
	if Global.playerAlive:
		nav_agent.target_position = player.global_position

func _on_timer_timeout():
	makepath()
 
func enemy():
	pass


func playerAttackCheck():
	if playerAttackInRange and damageCooldown and Global.playerAttacking:
		life -= 1
		Global.damageGiven = true
		damageCooldown = false
		recentlyHit = true
		$DamageCooldown.start()

func checkHit():
	if recentlyHit:
		recentlyHit = false

func _on_damage_cooldown_timeout():
	damageCooldown = true 

func _on_enemy_hitbox_area_exited(area:Area2D):
	if area.has_method("attackPath"):
		playerAttackInRange = false

func _on_enemy_hitbox_area_entered(area:Area2D):
	if area.has_method("attackPath"):
		playerAttackInRange = true
