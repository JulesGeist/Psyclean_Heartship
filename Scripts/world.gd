extends Node2D

var trash_standard = preload("res://Scenes/trash.tscn")
var dancer_scene = preload("res://Scenes/dancer.tscn")

# UI Components
@onready var hotbar = $UI/Hotbar
@onready var inventory_menu = $UI/InventoryMenu
@onready var equipment_slots = $UI/EquipmentSlots
@onready var drag_preview = $UI/DragPreview

var STARTING_DANCERS = 10

var score
var dancers_spawned = []
var trash_distances = {}

func _ready():
	for i in STARTING_DANCERS:
		dancers_spawned.append(spawn_dancer())
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var inv_name = item_slot.get_inv_name()
		var index = item_slot.get_index()
		item_slot.gui_input.connect(_on_ItemSlot_gui_input.bind(inv_name, index))
		
func _process(_delta):
	pass

func _physics_process(delta):
	# Setup the main players pathfinding
	if !$Player_Sucker.setup || !$Player_Psychonaut.setup:
		await get_tree().physics_frame
		$Player_Sucker.setup = true
		$Player_Psychonaut.setup = true
	var target = $Player/FollowPointLeft.position + $Player.position
	$Player_Sucker.set_movement_target(target)
	target = $Player/FollowPointRight.position + $Player.position
	$Player_Psychonaut.set_movement_target(target)
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_menu"):
		if inventory_menu.visible and drag_preview.dragged_item: return
		hotbar.visible = !hotbar.visible
		inventory_menu.visible = !inventory_menu.visible
		equipment_slots.visible = !equipment_slots.visible
		
		
func _on_ItemSlot_gui_input(event, inv_name, index):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if inventory_menu.visible:
				drag_item(inv_name, index)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if inventory_menu.visible:
				split_item(inv_name, index)
	if event is InputEventMouseMotion:
		var inventory_item = Inventory.get_inv_items(inv_name)[index]
		if inventory_item.has("inventory"):
			var item_inv_name = inventory_item["name"].to_lower()
			if !Inventory.inv_exists(item_inv_name):
				add_item_inventory(inventory_item)
			# object_name = item_inc_name + "Menu"
			# check if a node with this name exisits
			# create a new SlotContainer node, aim to have it under $UI
			# display the inventory on top of the main inventory
			# item should have an inventory and it should be displayed.
			pass
		
		
func _on_trash_spawn_timeout():
	var selected_dancer = randi() % dancers_spawned.size()
	spawn_trash(find_child(dancers_spawned[selected_dancer], false, false))
	
func add_item_inventory(item_object):
	var inv_data = item_object["inv_data"]
	var inv_name = item_object["name"].to_lower()
	var cols = inv_data["cols"]
	var rows = inv_data["rows"]
	var equipment_type = []
	if inv_data.has("equipment_type"):
		equipment_type = inv_data["equipment_type"]
	Inventory.new_inventory(inv_name, cols, rows, equipment_type)
	
	
func split_item(inv_name, index):
	var inventory_item = Inventory.get_inv_items(inv_name)[index]
	var dragged_item = drag_preview.dragged_item
	if !inventory_item or !inventory_item.stackable: return
	var split_amount = ceil(inventory_item.quantity / 2.0)
	if dragged_item and inventory_item.key == dragged_item.key:
		drag_preview.dragged_item.quantity += split_amount
		Inventory.set_item_quantity(inv_name, index, -split_amount)
	if !dragged_item:
		var item = inventory_item.duplicate()
		item.quantity = split_amount
		drag_preview.dragged_item = item
		Inventory.set_item_quantity(inv_name, index, -split_amount)

func drag_item(inv_name, index):
	var inventory_item = Inventory.get_inv_items(inv_name)[index]
	var dragged_item = drag_preview.dragged_item
	# pick item
	if inventory_item and !dragged_item:
		drag_preview.dragged_item = Inventory.remove_item(inv_name, index)
	# drop item
	elif !inventory_item and dragged_item:
		var equipment_type = Inventory.get_inv_data(inv_name)["equiptment_type"]
		if equipment_type != []:
			for i in equipment_type:
				if drag_preview.dragged_item[i]:
					drag_preview.dragged_item = Inventory.set_item(inv_name, index, dragged_item)
		else:
			drag_preview.dragged_item = Inventory.set_item(inv_name, index, dragged_item)
	elif inventory_item and dragged_item:
		# stack item
		if inventory_item.key == dragged_item.key and inventory_item.stackable:
			Inventory.set_item_quantity(inv_name, index, dragged_item.quantity)
			drag_preview.dragged_item = {}
	# swap items
	elif inventory_item and dragged_item:
		drag_preview.dragged_item = Inventory.set_item(inv_name, index, dragged_item)

func spawn_dancer():
	var dancer_instance = dancer_scene.instantiate()
	add_child(dancer_instance)
	return dancer_instance.name
	
func spawn_trash(dancer_node: Node):
	dancer_node.spawn_trash(trash_standard)

# Reccursively gets all children in the tree
# NOTE: Needs to be supplied with atleast one node to begin.
func get_all_children(node) -> Array:
	var nodes : Array = []
	
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
			
	return nodes
