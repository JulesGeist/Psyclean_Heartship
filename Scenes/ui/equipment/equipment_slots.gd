extends SlotContainer

var OFFSET = 64
# var INVENTORY_NAME = "equiped"

func _ready():
	INVENTORY_NAME = "equiped"
	var cols = 1
	var rows = 3
	slots = cols * rows
	item_types = ["equipable"]
	
	Inventory.new_inventory(INVENTORY_NAME, cols, rows, item_types)
	display_item_slots(INVENTORY_NAME, cols, rows)
	# await get_tree().proccess_frame
	position.x = ((get_viewport_rect().size.x - size.x) / 2) - OFFSET
	position.y = ((get_viewport_rect().size.y - size.y) / 2 )
	hide()
