extends GridContainer

var inventory = preload("res://Resources/Inventory.tres")

func _ready():
	inventory.item_changed.connect(_on_item_changed)
	update_inventory_slot_display()

func update_inventory_slot_display():
	var inventorySlotDisplay = get_child(0)
	inventorySlotDisplay.display_item(inventory.item)

func _on_item_changed():
	update_inventory_slot_display()
