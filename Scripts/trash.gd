extends RigidBody2D

func _ready():
	add_to_group("trash")

func remove_trash():
	
	self.queue_free()
