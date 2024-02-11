extends RigidBody2D

class_name TrashObject

@export var trash_type : String
@export var pickable : bool
@export var suckable : bool
@export var loot : String


func _ready():
	add_to_group("trash")

func remove_trash():
	
	self.queue_free()
