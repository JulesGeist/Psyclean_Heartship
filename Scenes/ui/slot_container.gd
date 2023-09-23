extends GridContainer

class_name SlotContainer

@export var ItemSlot: PackedScene

var INVENTORY_NAME = ""
var slots
var item_types

func display_item_slots(inv_name, cols, rows):
	columns = cols
	slots = cols * rows
	for index in range(slots):
		var item_slot = ItemSlot.instantiate()
		add_child(item_slot)
		item_slot.display_item(inv_name, Inventory.get_inv_items(inv_name)[index])
	Inventory.items_changed.connect(_on_Inventory_items_changed)

func _on_Inventory_items_changed(inv_name, indexes):
	if INVENTORY_NAME == inv_name:
		for index in (indexes + 1):
			if index < slots:
				var item_slot = get_child(index)
				if item_slot != null:
					item_slot.display_item(inv_name, Inventory.get_inv_items(inv_name)[index])
				else:
					pass
