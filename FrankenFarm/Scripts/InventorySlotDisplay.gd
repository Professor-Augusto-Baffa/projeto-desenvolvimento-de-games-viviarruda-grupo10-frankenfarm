extends CenterContainer

var itemTextureRect: TextureRect 

func _ready():
	itemTextureRect = $ItemTextureRect

func display_item(item):
	if item is Item:
		itemTextureRect.texture = item.texture
	else:
		itemTextureRect.texture = null