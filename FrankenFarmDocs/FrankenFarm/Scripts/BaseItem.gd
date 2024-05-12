extends Area2D
@export var item : Resource
@onready var sprite = $Sprite
var inventory = preload("res://Resources/Inventory.tres")
var canAddItem = false

func _ready():
	sprite.texture = item.texture

func _on_body_entered(_body:Node2D):
	canAddItem = true

func _on_body_exited(_body:Node2D):
	canAddItem = false

func _process(_delta):
	if Input.is_action_pressed("pick") and canAddItem:
		if inventory.add_item(item):
			queue_free()
	
