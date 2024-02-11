extends BoxItem


signal auto_collecting # will be sent to pocket when autocollect item is contained
signal slot_effect_activate # will be sent when effect_item is contained


var original_inventory_groups : PackedStringArray
var original_accepted_items : PackedStringArray
@export var character : Node2D

var tool : Node2D
	
# Called when the node enters the scene tree for the first time.
func _ready():
#	var new_inventory = preload("res://Scenes/ItemScenes/ItemInventory.tscn").instantiate()
#	new_inventory.name = "Inventory"
#	add_child(new_inventory)
	inventory = $Inventory
	inventory.slots = inventory_slots
	inventory.accepted_groups = inventory_groups
	super()
	inventory.visible = true
	$BG.visible = true
	inventory_opened = true
	original_inventory_groups = inventory_groups
	original_accepted_items = accepted_items
	immovable = true
	$Frame.visible = false
	
	
	# set the traits of the carried item to be the slot traits 
func copy_contained_item():
	var item = inventory.get_child(1)
	for group in item.get_groups():
		add_to_group(group)
	if item.inventory:
		inventory_groups.append_array(item.inventory_groups)
		if item.accepted_items:
			accepted_items = item.accepted_item
		if item.auto_collect:
			auto_collect = true
	inventory.update_from_parent()
	
func delete_contained_item():
	var item = inventory.get_child(1)
	inventory_groups.clear()
	inventory_groups = original_inventory_groups
	accepted_items = original_accepted_items
	auto_collect = false
	for group in item.get_groups():
		remove_from_group(group)
		add_to_group("Slot")
	inventory.update_from_parent()


func open_inventory():
	pass
func close_inventory():
	pass

func _on_mouse_exited():
	$Frame.visible = false
	return

func _on_mouse_entered():
	pass
	
func _on_inventory_opening():
	$BG.size.x = inventory.columns * 20
	$BG.size.y = (inventory.slots / inventory.columns) * 20
	inventory.visible = true
	
	
func spawn_item(item : String):
	var new_item = load(item).instantiate()
	if inventory.can_item_enter(new_item) == true:
		inventory.add_child(new_item)
	else:
		print("item cannot spawn in your pocket.")


	
func _on_child_entered_tree(node):
	if inventory:
		if inventory.get_child_count() > 0:
			if inventory.get_child(1).auto_collect == true:
				if inventory.get_child(1).inventory.can_item_enter():
					inventory.get_child(1).add_to_inventory(node)
					return
		elif inventory.can_item_enter(node):
			add_to_inventory(node)


#func _on_child_exiting_tree(node):
#	if node.is_in_group("EffectItem"):
#		node.deactivate_slot_effect()
#		delete_contained_item()
#		emit_signal("slot_effect_activate")

#func _on_item_entered(node):
#	instantiate_tool(node)
	
	
func instantiate_tool(node):
	if character:
		if node.is_in_group("Tool"):
				var effect_node = preload("res://Scripts/Tool.tscn").instantiate()
				effect_node.tool_type = node.tool_type
				effect_node.character = character # the carrier character
				effect_node.tool_item = node # the initiator of the effect
	#			effect_node.target_object = node.target_object # group that the affected object is in
	#			effect_node.target_element = node.element # group that the affected object is in
	#			effect_node.slot_effect = node.slot_effect
				character.add_child(effect_node)
				tool = effect_node
				emit_signal("slot_effect_activate", character)
				print("tool spawned at character: ", character)

	
func _on_item_left(node):
	if character:
		if node.is_in_group("Tool"):
			tool.queue_free()



func _on_inventory_child_entered_tree(node):
	instantiate_tool(node)
