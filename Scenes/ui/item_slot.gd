extends ColorRect

@onready var item_icon = $ItemIcon
@onready var item_quantity = $ItemQuantity

var inventory_name

	
func display_item(inv_name, item):
	if item:
		item_icon.texture = load("res://Assets/images/%s" % item.icon)
		item_quantity.text = str(item.quantity) if item.stackable else ""
		inventory_name = inv_name
	else:
		item_icon.texture = null
		item_quantity.text = ""
		inventory_name = inv_name
		
func get_inv_name():
	return inventory_name
	
func set_inv_name(inv_name):
	inventory_name = inv_name
