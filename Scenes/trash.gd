extends RigidBody2D

class_name Trash

@export var trash_type : String
@export var pickable : bool = true
@export var suckable : bool
@export var loot : String = "trash"


func _ready():
	add_to_group("pickable")
	if loot == null:
			loot = "trash"
			
func remove_trash():
	
	self.queue_free()
