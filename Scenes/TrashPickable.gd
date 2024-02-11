extends RigidBody2D

class_name TrashPickable

@export var trash_type : String
@export var pickable : bool = true
@export var suckable : bool
@export var loot : String = "trash"


func _ready():
	add_to_group("pickable")
	
func _process(delta):
	
	pass


func remove_trash():

	self.queue_free()

func _on_body_entered(body):
	if body.is_in_group("character"):
		powerup_action()
		self.queue_free()
		
func powerup_action():
	pass
