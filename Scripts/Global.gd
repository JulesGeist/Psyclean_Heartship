# SOURCE: https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7

extends Node2D

@onready var trash : int
@onready var moral : float
@onready var moral_drain_divider : float = 2 # reduces moral drain by division of global.trash
@onready var max_moral : float
@onready var items
@onready var active_character : String
var buttcoins : int

var sucking : bool
var cursor_item : Control
 

func _ready():

	active_character = "Picker"
	max_moral = 300
	moral = max_moral
	

# await time(1) to wait 1 sec inside a function
func time(seconds): 
	await get_tree().create_timer(seconds).timeout


