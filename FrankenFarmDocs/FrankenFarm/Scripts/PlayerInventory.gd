extends Node2D

var base_item = preload("res://Scenes/Item.tscn")
var inventory = preload("res://Resources/Inventory.tres")
@onready var item = $ItemOnHold
var parent
var parentBody
var rng
var itemSprite

func _ready():
	inventory.item_dropped.connect(_on_item_dropped)
	inventory.item_changed.connect(_on_item_changed)
	parent = get_parent()
	itemSprite = item.get_node("ItemSprite")
	rng = RandomNumberGenerator.new()

func _on_item_dropped():
	var item_instance = base_item.instantiate()
	item_instance.item = inventory.item
	item_instance.global_rotation_degrees = rng.randf_range(0, 360)
	item_instance.global_position = global_position
	parent.get_parent().get_parent().add_child(item_instance)
	inventory.remove_item()

func _on_item_changed():
	if inventory.item != null:
		itemSprite.texture = inventory.item.texture
	else:
		itemSprite.texture = null

func _process(_delta):
	if Input.is_action_pressed("drop") and inventory.item != null:
		inventory.emit_signal("item_dropped")
