extends BaseInventory

class_name ItemInventory


	
# Called when the node enters the scene tree for the first time.
func _ready():
	expand = 1
	add_to_group("ItemInventory")
	add_to_group("Inventory")
	




func closing():
	# as long as theres a cursor item from this inventory, dont close.
	if Global.cursor_item != null:
		if get_children().has(Global.cursor_item):
			return false
	elif not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
				get_parent().close_inventory()
				return true
		
	
func _on_mouse_exited():
	if get_parent().is_in_group("BoxItem"):
		if get_parent().immovable == true:
			return
	elif get_parent().is_in_group("InventoryItem"):
		closing()


