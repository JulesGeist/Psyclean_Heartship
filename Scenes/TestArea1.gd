extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_button_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var new_item = load("res://Scenes/ItemScenes/BaseItem.tscn").instantiate()
			new_item.inventory_slots = 3
			new_item.texture = load("res://Assets/images/objects/ME_Singles_Camping_16x16_Backpack_3.png")
			$BaseItem/Inventory.add_child(new_item)



func _on_button_2_gui_input(event):
	if event is InputEventMouseButton:
		if Global.cursor_item != null:
			var dropped_item = Global.cursor_item
			Global.cursor_item = null
			dropped_item.queue_free()


func _on_trashbags_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var new_item = load("res://Scenes/ItemScenes/Equipment/trashbag_small.tscn").instantiate()
			$BaseItem/Inventory.add_child(new_item)
