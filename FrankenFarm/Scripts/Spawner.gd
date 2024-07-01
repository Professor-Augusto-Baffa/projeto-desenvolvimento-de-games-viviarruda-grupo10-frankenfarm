extends Node2D

@export var enemy_scene: PackedScene

@export var number_of_enemies: int = 5

var spawnedEnemies = 0

@export var player: Node2D

var canSpawn = true

func spawn_enemies():
	if enemy_scene == null:
		print("Enemy scene is not assigned")
		return
	spawnedEnemies += 1
	var enemyInstance = enemy_scene.instantiate()
	enemyInstance.player = player
	enemyInstance.z_index = 1
	enemyInstance.global_position = global_position
	get_parent().add_child(enemyInstance)

func _on_spawn_timer_timeout():
	canSpawn = true
	
func spawnHandling():
	if canSpawn and Global.nightTime:
		spawn_enemies()
		canSpawn = false

func _physics_process(_delta):
	if spawnedEnemies >= number_of_enemies: 
		canSpawn = false
		Global.numberOfSpawners -= 1
		queue_free()
	spawnHandling()





