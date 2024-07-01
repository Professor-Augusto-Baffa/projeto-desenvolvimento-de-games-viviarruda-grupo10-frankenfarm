extends Sprite2D

var target

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_parent().get_node("BetesteinArm1")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = target.targetPos 
	pass
