extends Node2D

var base_item = preload("res://Scenes/Item.tscn")
var spawner = preload("res://Scenes/Spawner.tscn")
var betestein = preload("res://Scenes/Betestein.tscn")
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
	if Global.playerCanPlant and inventory.item.name == "Seed" and not Global.nightTime:
		var enemy_spawner = spawner.instantiate()
		enemy_spawner.global_rotation_degrees = rng.randf_range(0, 360)
		enemy_spawner.global_position = global_position
		enemy_spawner.player = parent.get_parent()
		enemy_spawner.enemy_scene = betestein
		parent.get_parent().get_parent().add_child(enemy_spawner)
		Global.numberOfSpawners += 1
		Global.planted = true
	else:
		var item_instance = base_item.instantiate()
		item_instance.item = inventory.item
		item_instance.global_position = global_position
		item_instance.canBePickedUp = false
		item_instance.global_rotation_degrees = rng.randf_range(0, 360)
		parent.get_parent().get_parent().add_child(item_instance)
	inventory.remove_item()

func _on_item_changed():
	if inventory.item != null:
		item.itemName = inventory.item.name
		itemSprite.texture = inventory.item.texture
	else:
		item.itemName = ""
		itemSprite.texture = null

func _process(_delta):
	if Input.is_action_pressed("drop") and inventory.item != null:
		inventory.emit_signal("item_dropped")
