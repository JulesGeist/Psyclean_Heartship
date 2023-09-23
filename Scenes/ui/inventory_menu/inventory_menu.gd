extends SlotContainer

# var INVENTORY_NAME = "main"

func _ready():
	INVENTORY_NAME = "main"
	var cols = 9
	var rows = 3
	slots = cols * rows
	if !Inventory.inv_exists(INVENTORY_NAME): # Also possible to setup in hotbar.gd
		Inventory.new_inventory(INVENTORY_NAME, cols, rows)
		Inventory.load_test_data()
	display_item_slots(INVENTORY_NAME, cols, rows)
	# await get_tree().proccess_frame
	position = (get_viewport_rect().size - size) / 2
	hide()
