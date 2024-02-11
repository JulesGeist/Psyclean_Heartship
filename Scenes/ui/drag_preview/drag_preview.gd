extends Control


@onready var item_icon = $ItemIcon


func _process(_delta):
	if Global.cursor_item: # if dragged_item is not empty
		set_dragged_item()
		position.x = get_global_mouse_position().x + 10
		position.y = get_global_mouse_position().y + 10
	else: 
		visible = false
		
func set_dragged_item():
	if Global.cursor_item:
		item_icon.texture = Global.cursor_item.texture
		#load("res://Assets/images/%s" % dragged_item.icon) <- original code
		$ItemName.text = Global.cursor_item.item_name
		visible = true
	else:
		item_icon.texture = null
		visible = false
