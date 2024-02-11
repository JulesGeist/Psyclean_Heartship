extends NinePatchRect

@onready var picker_slot : Node = $PickerSlot
@onready var sucker_slot : Node = $SuckerSlot
@onready var toy_slot : Node = $ToySlot
@onready var pocket : Node = $Pocket
@onready var tool_slot : Node = $ToolSlot

var opened = false
var tween : Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		pass



func open_inventory():

	visible = true
	#tween.tween_property($".", "size", Vector2(193,104), 3.0)
	opened = true
	#emit_signal("opening")
	
func close_inventory():
	#tween.tween_property($".", "size", Vector2(1,1), 3.0)
	#emit_signal("closing")
	visible = false
	opened = false
	update_tools()
	
	
func selected_slot():
	var select_slot : Node
	var mouse_position = get_local_mouse_position()
	for slot in find_children("Slot"):
		if Rect2(Vector2(), slot.size).has_point(get_local_mouse_position()):
			select_slot = slot
			return select_slot
			
			
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == false:
			# if theres no cursor item, make it this one:
			if Global.cursor_item == null:
					return
			elif find_parent(Global.cursor_item.name) == Global.cursor_item:
				Global.cursor_item = null
				print("tried to put mother item in daughter item.")
				return
			# if there is an item on the cursor, look if it can be added and add it.
			elif Global.cursor_item != null:
				var selected_slot = selected_slot()
				if selected_slot.filled >= selected_slot.slots:
					print("this slot is full")
					return
				else:
					add_to_inventory(Global.cursor_item)
					Global.cursor_item = null
					return


func add_to_inventory(item: BaseItem):
		if pocket.can_item_enter(item):
			item.reparent(pocket, false)
		else: print("can't store item.")

func _on_pocket_child_entered_tree(node):
	print("item in pocket: ", node.item_name)

func _on_toy_slot_child_entered_tree(node):
	pass

func update_tools():
	if $"root/World/Player/Tool":
		$"root/World/Player/Tool".slot_effect = $PickerSlot/Inventory.get_child(1).slot_effect
	if $"root/World/Player_Sucker/Tool":
		$"root/World/Player_Sucker/Tool".slot_effect = $SuckerSlot/Inventory.get_child(1).slot_effect	
	if $"root/World/Player_Psychonaut/Tool":
		$"root/World/Player_Psychonaut/Tool".slot_effect = $ToySlot/Inventory.get_child(1).slot_effect
	print("slots updated!")
