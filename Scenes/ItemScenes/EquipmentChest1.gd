extends AnimatedSprite2D

@export var stored_items : Array[PackedScene]
@export var slots: int
@export var columns : int
var in_range = false
var open = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$BoxItem.slots = slots
	$BoxItem.columns = columns
	$BoxItem.visible = false
	if not stored_items.is_empty():
		var scene 
		for item in stored_items:
			scene = item.instantiate()
			$BoxItem.inventory.add_child(scene)
			

	set_frame(0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_mouse_shape_entered(shape_idx):
	if in_range == true:
		play("open")
		$BoxItem.visible = true
		$BoxItem.open_inventory()
		open = true
		await Global.time(2)

func _on_area_2d_body_entered(body):
		if body.is_in_group("Character"):
			in_range = true
			play("open")
			$BoxItem.visible = true
			$BoxItem.open_inventory()
			open = true
			await Global.time(2)


func _on_area_2d_mouse_shape_exited(shape_idx):
	if in_range:
		if $BoxItem.inventory_opened:
			return
	elif $BoxItem.inventory_opened == true:
			await Global.time(2)
			play("close")
			$BoxItem.visible = false
			open = false
	

func _on_area_2d_body_exited(body):
	var bodies = $Area2D.get_overlapping_bodies()
	if not bodies.is_empty():
		for bodi in bodies:
			if bodi.is_in_group("characters"):
				in_range = true
	else:
		in_range = false



func _on_area_2d_mouse_entered():
	if in_range:
		if $BoxItem.inventory_opened:
			return
	elif $BoxItem.inventory_opened == true:
			await Global.time(2)
			play("close")
			$BoxItem.visible = false
			open = false


func _on_area_2d_mouse_exited():
	if in_range:
		if $BoxItem.inventory_opened:
			return
	elif $BoxItem.inventory_opened == true:
			await Global.time(2)
			play("close")
			$BoxItem.visible = false
			open = false

func _on_tree_entered():
	pass
