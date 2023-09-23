extends SlotContainer

var OFFSET = 24

func _ready():
	INVENTORY_NAME = "main"
	if !Inventory.inv_exists(INVENTORY_NAME): # Also possible to setup in inventory_main.gd
		var main_cols = 9
		var main_rows = 3
		Inventory.new_inventory(INVENTORY_NAME, main_cols, main_rows)
		Inventory.load_test_data()
	var cols = Inventory.get_inv_data(INVENTORY_NAME)["cols"]
	var rows = 1
	slots = cols * rows
	display_item_slots(INVENTORY_NAME, cols, rows)
	# await get_tree().proccess_frame
	position.x = (get_viewport_rect().size.x - size.x) / 2
	position.y = get_viewport_rect().size.y - size.y - OFFSET
