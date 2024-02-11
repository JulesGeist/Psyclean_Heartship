extends BaseItem

class_name BoxItem

@export var immovable : bool
@export var only_drop : bool
@export var only_extract : bool # if true, player can not drop items into the box
@export var slots : int
@export var columns : int
@export var slot_type : String
@export var accepted_groups : PackedStringArray
@export var accepted_items : PackedStringArray



func _init(i_immovable = false, i_only_drop = false, i_only_extract = false, i_slots = 6, i_columns = 3, i_type = "Random", i_accepted_groups = [], i_accepted_items = []):
	super()
	only_extract = i_only_extract
	slots = i_slots
	columns = i_columns
	slot_type = i_type
	accepted_groups = i_accepted_groups
	accepted_items = i_accepted_items
	only_drop = i_only_drop
	immovable = i_immovable
	
# Called when the node enters the scene tree for the first time.
func _ready():
	inventory = $Inventory
	if columns == 0:
		columns = 1
	$BG.size.x = columns * 20
	$BG.size.y = (slots / columns) * 20
	inventory.columns = columns
	inventory.slots = slots
	inventory.slot_type = slot_type
	inventory.accepted_groups = accepted_groups
	inventory.expand = 3
	inventory.visible = false
	
	
	add_to_group("Item", true)
	add_to_group("InventoryItem", true)
	add_to_group("BoxItem", true)
	texture_normal = texture
	$BG.texture = bg_normal
	$ItemBG.texture = bg_normal
	$CursorPreview.texture = texture
	$CursorPreview.visible = false
	inventory_opened = false
	$Frame.visible = false
	$BG.visible = false
	
	if fill_bar == true:
		var new_fillbar = preload("res://Scenes/ItemScenes/FillBar.tscn").instantiate()
		add_child(new_fillbar)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	
	if inventory.get_child_count() == 0:
		$ItemBG.texture = bg_normal
	else:
		$ItemBG.texture = bg_active
	
	# cursor preview on or off based on global
	if immovable == false:
		if Global.cursor_item == self:
			$CursorPreview.position = get_global_mouse_position()
		else:
			$CursorPreview.visible = false
		
	if only_drop == true:
		if inventory.get_children().has(Global.cursor_item):
			Global.cursor_item = null
			print("taking items is not allowed here.")
			
func add_to_inventory(item: BaseItem):
	if item != self:
		if only_drop == false:
			if can_enter_slot_type(item):
				if is_accepted_item(item):
					if inventory.can_item_enter(item):
						inventory.add_to_inventory(item)
						
						return true
					else: 
						print("can't add item here.")
						return false 
				else: 
					print("item not accepted.")
					return false 
			else: 
				print("wrong item type.")
				return false
		else: 
			print("no item dropping allowed.")
			return false
	else: 
		printerr("cannot add item to itself!")
		return false

func is_accepted_item(item):
	if accepted_items.is_empty():
		return true
	elif accepted_items.has(item.item_name):
		return true
	else:
		return false

func can_enter_slot_type(item):
	if slot_type != "":
		if item.item_type.to_lower() == slot_type.to_lower():
			return true
		else:
			return false
	else:
		return true



func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == false:
			# if theres no cursor item:
			if Global.cursor_item == null:
				if immovable == false:
					if Rect2(Vector2(), $ItemBG.size).has_point(get_local_mouse_position()):
						emit_signal("pressed")
						cursor_preview()
						Global.cursor_item = self
						print("item selected")
						return
					else:
						for child in get_children():
							if Rect2(Vector2(), child.size).has_point(get_local_mouse_position()):
								return
				else:
					print("item cannot be picked.")
					return
				
			# if the mother item gets dragged onto a child item:
			elif Global.cursor_item == get_parent().get_parent():
				Global.cursor_item = null
				return
				
			# if there is an item on the cursor, look if it can be added and add it.
			elif Global.cursor_item != self:
				if only_extract == false:
					$Inventory.add_to_inventory(Global.cursor_item)
					print("item added")
					Global.cursor_item = null
					return
				else:
					print("items cannot be dropped here.")
					return
			elif Global.cursor_item == self:
				Global.cursor_item = null
				return

func close_inventory():
	await Global.time(0.3)
	if inventory.are_child_inventories_closed():
		if not Rect2(Vector2(), $ItemBG.size).has_point(get_local_mouse_position()):
			if not Rect2(Vector2(), $BG.size).has_point(get_local_mouse_position()):
				if not inventory.get_children().has(Global.cursor_item):
					inventory.visible = false
					$BG.visible = false
					inventory_opened = false
				

func open_inventory():
	await Global.time(0.2)
	if Rect2(Vector2(), $BG.size).has_point(get_local_mouse_position()):
		r_open()
		size = $BG.size
		inventory_opened = true
		$BG.visible = true
		
func _on_mouse_entered():
	if inventory_visibility == true:
		open_inventory()
	$Frame.visible = true
		
func _on_mouse_exited():
	if inventory_visibility == true:
			close_inventory()
	$Frame.visible = false
	if parent_inventory is ItemInventory:
		parent_inventory.closing()
