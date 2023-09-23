extends Node

signal items_changed(inv_name, indexes)

var cols = 9
var rows = 3
var slots = cols * rows
var inventories : Dictionary = {}

func _ready():
	pass
	
func load_test_data():
	get_inv_items("main")[0] = Global.get_item_by_key("sword")
	get_inv_items("main")[1] = Global.get_item_by_key("armor")
	get_inv_items("main")[2] = Global.get_item_by_key("apple")
	get_inv_items("main")[3] = Global.get_item_by_key("apple")
	get_inv_items("main")[4] = Global.get_item_by_key("potion")
	get_inv_items("main")[5] = Global.get_item_by_key("picker")
	
func get_inv_data(inv_name):
	return inventories[inv_name]["inv_data"]
	
func get_inv_items(inv_name):
	return inventories[inv_name]["items"]
	
func inv_exists(inv_name):
	var result = inventories.find_key(inv_name)
	if result == null:
		return false
	return true

func set_item(inv_name, index, item):
	var previous_item = get_inv_items(inv_name)[index]
	get_inv_items(inv_name)[index] = item
	items_changed.emit(inv_name, index)
	# emit_signal("items_changed", [inv_name, index])
	return previous_item
	
func add_item(inv_name,key):
	var index = 0
	for i in get_inv_items(inv_name):
		if i == {}:
			get_inv_items(inv_name)[index] = Global.get_item_by_key(key)
			items_changed.emit(inv_name, index)
			# emit_signal("items_changed", [inv_name, index])
			return index
		index += 1
	printerr("Inventory " + str(inv_name) + " is full - 
	probably want to send a signal so we can tell the player")

func remove_item(inv_name, index):
	var previous_item = get_inv_items(inv_name)[index].duplicate()
	get_inv_items(inv_name)[index].clear()
	# emit_signal("items_changed", [inv_name, index])
	items_changed.emit(inv_name, index)
	return previous_item

func set_item_quantity(inv_name, index, amount):
	get_inv_items(inv_name)[index].quantity += amount
	if get_inv_items(inv_name)[index].quantity <= 0:
		remove_item(inv_name, index)
	else:
		items_changed.emit(inv_name, index)
		# emit_signal("items_changed", [inv_name, index])

func get_item_index(inv_name, key):
	var index = -1
	for i in get_inv_items(inv_name):
		index += 1
		if i["key"] == key:
			break
	if index >= 0:
		return index
	else:
		printerr("Item not found in " + str(inv_name) + " Inventory")

func is_in_inventory(inv_name, key):
	for i in get_inv_items(inv_name):
		if i == {}:
			continue
		elif i["key"] == key:
			return true
	return false
	
func new_inventory(inv_name, new_cols, new_rows, equipment_type: Array = []):
	var new_slots = new_cols * new_rows
	var items = []
	
	inventories[inv_name] = {}
	inventories[inv_name]["inv_data"] = {
		"cols" = new_cols, 
		"rows" = new_rows, 
		"slots" = new_slots,
		"equiptment_type" = equipment_type
		}
	for i in range(new_slots):
		items.append({})
	inventories[inv_name]["items"] = items
