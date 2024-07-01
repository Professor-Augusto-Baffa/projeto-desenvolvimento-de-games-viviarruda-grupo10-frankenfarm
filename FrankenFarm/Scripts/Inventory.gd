extends Resource
class_name Inventory

signal item_changed()
signal item_dropped()

@export var item : Resource

func _ready():
  item = null

func set_item(_item):
  var previousItem = item
  item = _item
  emit_signal("item_changed")
  return previousItem

func remove_item():
  var previousItem = item
  item = null
  emit_signal("item_changed")
  return previousItem

func add_item(_item):
  if item != null:
    if _item != item:
      emit_signal("item_dropped")
      remove_item()
    else:
      return false
  set_item(_item)
  return true





