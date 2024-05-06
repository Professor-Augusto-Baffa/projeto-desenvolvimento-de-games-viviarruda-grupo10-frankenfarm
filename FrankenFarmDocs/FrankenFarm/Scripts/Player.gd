extends CharacterBody2D

const Speed = 520.0
const Accel = 50.0

func _physics_process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")

	velocity.x = move_toward(velocity.x, Speed * direction.x, Accel)
	velocity.y = move_toward(velocity.y, Speed * direction.y, Accel)

	move_and_slide()