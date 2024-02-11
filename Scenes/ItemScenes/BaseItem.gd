extends TextureButton

class_name BaseItem

@export var item_name : String
@export var item_type : String
@export var texture : Texture2D # or Resource?
@export var inventory_slots : int
@export var inventory_groups : PackedStringArray # the accepted_groups of the inventory
@export var fill_bar : bool # activates a progress-bar next to item icon, showing capacity of its inventory#
@export var inventory_visibility : bool #if inventory will be visible at all
@export var auto_collect : bool # automatically collects items from the parent inventory into its own inventory 


@onready var bg_active = preload("res://Assets/images/Item_BG_active.png")
@onready var bg_normal = preload("res://Assets/images/Item_BG_normal.png")

var inventory : Node  # the inventory of this item
var parent_inventory : Node # where this item sits in
@onready var inventory_opened : bool = false

#------------------------

#------------------------
func _init(i_name = "BaseItem", i_type = "loot", i_slots = 0, i_fillbar = false, i_groups = [], i_inventory_visibility = false, i_auto_collect = false):
	item_name = i_name
	item_type = i_type
	inventory_slots = i_slots
	fill_bar = i_fillbar
	inventory_groups = i_groups
	inventory_visibility = i_inventory_visibility
	auto_collect = i_auto_collect
	
func _ready():
	add_to_group("Item", true)
	texture_normal = texture
	$CursorPreview.texture = texture
	$CursorPreview.visible = false
	inventory_opened = false
	$BG.texture = bg_normal
	$Frame.visible = false

	if inventory_slots > 0:
		add_to_group("InventoryItem")
		if get_node_or_null("Inventory") == null:
			var new_inventory = preload("res://Scenes/ItemScenes/ItemInventory.tscn").instantiate()
			new_inventory.name = "Inventory"
			add_child(new_inventory)

		inventory = $Inventory
		inventory.slots = inventory_slots
		inventory.accepted_groups = inventory_groups
		inventory.position.y = 20
		inventory.visible = false

		if fill_bar == true:
			var new_fillbar = preload("res://Scenes/ItemScenes/FillBar.tscn").instantiate()
			add_child(new_fillbar)
		
		inventory.connect("item_entered", Callable(self, "_on_item_entered"))
		inventory.connect("item_left", Callable(self, "_on_item_left"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if inventory:
		if inventory.get_child_count() == 0:
			$BG.texture = bg_normal
		else:
			$BG.texture = bg_active

	
	# cursor preview on or off based on global
	if Global.cursor_item == self:
		$CursorPreview.position = get_global_mouse_position()
	else:
		$CursorPreview.visible = false
		
	
	
func cursor_preview():
	$CursorPreview.position.x = get_global_mouse_position().x +20
	$CursorPreview.position.y = get_global_mouse_position().y +20
	Global.cursor_item = self
	$CursorPreview.visible = true
	print("item selected")
	
func _on_pressed():
	pass
	
# when clicked, button will be pressed and preview icon appears
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == false:
			# if theres no cursor item, make it this one:
			if Global.cursor_item == null:
				if Rect2(Vector2(), size).has_point(get_local_mouse_position()):
					emit_signal("pressed")
					cursor_preview()
					return
				else:
					return
			# if the mother item gets dragged onto a child item:
			elif find_parent(Global.cursor_item.name) == Global.cursor_item:
				Global.cursor_item = null
				print("tried to put mother item in daughter item.")
				return
			# if there is an item on the cursor, look if it can be added and add it.
			elif Global.cursor_item != self:
				if inventory:
					if inventory.can_item_enter(Global.cursor_item):
						inventory.add_to_inventory(Global.cursor_item)
						Global.cursor_item = null
						return
				else:
					return
			elif Global.cursor_item == self:
				Global.cursor_item = null
				return

func add_to_inventory(item: BaseItem):
	inventory.add_to_inventory(item)




func close_inventory():
	await Global.time(0.3)
	if Global.cursor_item:
		if inventory.contains_item(Global.cursor_item) == -1:
			return
	if inventory.are_child_inventories_closed():
		if not Rect2(Vector2(), $BG.size).has_point(get_local_mouse_position()):
			inventory.visible = false
			$Frame.size = Vector2(26,26)
			$BG.size = Vector2(20,20)
			inventory_opened = false
	else: return


func open_inventory():
	await Global.time(0.2)
	if Rect2(Vector2(), $BG.size).has_point(get_local_mouse_position()):
		if inventory.expand == 3:
			r_open()
		elif get_parent() is ItemInventory:
			parent_inventory = get_parent()
			if parent_inventory.expand == 1: #if parent expands vertically, expand horizontally:
				h_open()
			if parent_inventory.expand == 2: #if parent expands horizontally, expand vertically:
				v_open()
			if parent_inventory.expand == 3:
				v_open()
		else: # if parent expands elsehow (or null), expand vertically:
			v_open()
		inventory_opened = true
	$Frame.size.x = $BG.size.x +5
	$Frame.size.y = $BG.size.y +6
		

func h_open():
	inventory.expansion(2)
	$BG.size.x = inventory_slots * 20
	inventory.visible = true

func v_open():
	inventory.expansion(1)
	$BG.size.y = inventory_slots * 20
	inventory.visible = true

func r_open():
	inventory.expansion(3)
	$BG.size.x = inventory.columns * 20
	$BG.size.y = (inventory.slots / inventory.columns) * 20
	inventory.visible = true
	
	
func _on_mouse_entered():
	$Frame.visible = true
	if inventory:
		if inventory_visibility == true:
			open_inventory()
			

func _on_mouse_exited():
	if inventory:
		if inventory_visibility == true:
			close_inventory()
	if parent_inventory is ItemInventory:
		parent_inventory.closing()
	$Frame.visible = false


func _on_child_entered_tree(node):
	if node.is_in_group("Item"):
			add_to_inventory(node)




func _on_child_exiting_tree(node):
	if inventory:
		if inventory_visibility == true:
			close_inventory()


# auto_collect function, triggered by parent inventory signal child_entered
func on_parent_inventory_income(node):
	if auto_collect:
		if inventory.can_item_enter(node):
			var auto_item = node
			await get_tree().physics_frame
			print("autocollect signal sent: ", auto_item)
			auto_item.reparent(inventory)
			return
		else:
			print("no auto-collect happened")
			
	else:
		return


func get_contained_items(group_filter : String = ""):
	if inventory:
		var contained_items = inventory.get_children()
		var filtered_items = []
		if not group_filter == "":
			for item in contained_items:
				if item.is_in_group(group_filter):
					filtered_items.append(item)
			return filtered_items
		else: 
			return contained_items
	else: 
		return false


func _on_item_entered(node):
	pass
	
func _on_item_left(node):
	pass

func _on_tree_entered():
	pass
