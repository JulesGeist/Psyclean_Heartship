extends TextureProgressBar

class_name FillBar

var max_amount : float
var amount : float = 0
var smooth : float = 0
var inventory : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory = get_node("../Inventory")
	max_amount = inventory.slots
	max_value = max_amount
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	await get_tree().physics_frame
	amount = inventory.filled
	value = amount
	

