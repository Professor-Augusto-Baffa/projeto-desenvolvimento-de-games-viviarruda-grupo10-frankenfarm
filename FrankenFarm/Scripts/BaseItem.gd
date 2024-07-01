extends Area2D
@export var item : Resource
var canBePickedUp = true
@onready var sprite = $Sprite
var inventory = preload("res://Resources/Inventory.tres")
var canAddItem = false

func _ready():
	sprite.texture = item.texture
	if not canBePickedUp:
		$CanBePickedUpTimer.start()

func _on_body_entered(_body:Node2D):
	canAddItem = true

func _on_body_exited(_body:Node2D):
	canAddItem = false

func _process(_delta):
	if Input.is_action_pressed("pick") and canAddItem and canBePickedUp:
		if inventory.add_item(item):
			queue_free()
	
func _on_can_be_picked_up_timer_timeout():
	canBePickedUp = true

