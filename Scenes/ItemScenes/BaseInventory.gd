extends GridContainer

class_name BaseInventory

@export var slots : int
@export var slot_type : String
@export var accepted_groups : PackedStringArray
var parent : Node
var filled : float = 0.0
@export var expand : int = 1 # 1= expand vertically // 2= expand horizontally // 3= expand both

signal item_entered (node)
signal item_left (node)

# initialize defaults
func _init(i_slots = 1, i_slot_type = "", i_accepted_groups = []):
	slots = i_slots
	slot_type = i_slot_type
	accepted_groups = i_accepted_groups

	
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().physics_frame
	
	add_to_group("Inventory", true)
	parent = get_parent()
	item_entered.connect(Callable(parent, "_on_item_entered"))
	item_left.connect(Callable(parent, "_on_item_left"))
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	filled = get_child_count()


# determines in which direction the inventory will open
func expansion(state : int):
	# if "state" is given, replace expand with the new state.
	# this makes sure that the next inventory gets the mother-inventory direction via expand
	if state != null: 
		expand = state

		# 2 = horizontal
	if expand == 2:
		set_columns(slots)
		anchor_right
		position.x = 20
		position.y = 0
		size.x = slots * 20
		
		# 1 = vertical
	if expand == 1:
		set_columns(1)
		anchor_bottom
		position.x = 0
		position.y = 20
		size.y = slots * 20
		
		# 3 = rectangular
	if expand == 3:
		anchor_right
		position.x = 0
		position.y = 20
		size.x = columns * 20
		size.y = (slots / columns) * 20

func can_item_enter(item : BaseItem):
	if filled >= slots:
		print("no empty slot")
		return false
	# if no group is in accepted_groups = all groups are accepted:
	elif accepted_groups.is_empty():
		print("item can enter.")
		return true
	else:
		for group in accepted_groups:
			if item.is_in_group(group):
				print("item can enter.")
				return true
			else: continue
		# if not in any accepted groups, return false:
		print("item group not accepted here")
		return false
			
func contains_item(item : BaseItem):
	if not is_instance_valid(item):
		push_warning("item is invalid")
		return -1
	var answer = 0
	if filled >= 1:
		for entry in get_children():
			if entry == item:
				answer = -1
				return answer
			elif entry.item_name == item.item_name:
				answer = +1
	return answer
				
			

func _on_child_entered_tree(node):
	emit_signal("item_entered", node)
	if node.auto_collect:
		self.connect("child_entered_tree", Callable(node, "on_parent_inventory_income"))
		print("auto_collect active: ", node)
		return
	
		
func _on_child_exiting_tree(node):
	if node.auto_collect:
		self.disconnect("child_entered_tree", Callable(node, "on_parent_inventory_income"))
		print("auto-collect inactive: " , node)
	filled -= 1
	emit_signal("item_left", node)
	queue_sort()
	get_parent().close_inventory()
	
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if Global.cursor_item == null:
			return
		# if its the same item as this one:
		if Global.cursor_item == get_parent():
			Global.cursor_item = null
			print("putting item back")
			return
		# if cursor item is already in the inventory:
		elif contains_item(Global.cursor_item) == -1:
			Global.cursor_item = null
			print("putting item back")
			return
		#if there is a cursor item, that is not the parent and not inside the inventory already:
		elif Global.cursor_item != null :
			var item_income = Global.cursor_item
			if can_item_enter(item_income):
				add_to_inventory(item_income)
				Global.cursor_item = null
			else:
				return
		else:
			return

func spawn_item(filepath: String):
	var new_item = load(filepath).instantiate()
	if can_item_enter(new_item) == true:
		add_child(new_item)
	else:
		print("item cannot spawn in this inventory.")
		return false

func add_to_inventory(item: BaseItem):
	if item != get_parent():
		if can_item_enter(item):
			item.reparent(self, false)
			emit_signal("item_entered")
		else: print("can't add item here. (BaseInventory > add_to_inventory)")
	else: 
		printerr("cannot add item to itself!")
		return false

func are_child_inventories_closed():
	for i in range(get_child_count()):
		if get_child(i).inventory_opened == true:
			return false
		else: continue
	return true
	
func update_from_parent():
	parent = get_parent()
	accepted_groups = parent.inventory_groups
	slots = parent.inventory_slots
	filled = get_child_count()


func _on_tree_entered():
	pass # Replace with function body.


