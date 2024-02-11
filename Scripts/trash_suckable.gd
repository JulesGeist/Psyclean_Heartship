extends RigidBody2D

class_name TrashSuckable

@export var trash_type : String
@export var pickable : bool
@export var suckable : bool = true
@export var loot : String 


func _ready():
	add_to_group("suckable")
	freeze = true
	loot = "nothing"
	
func remove_trash():
	
	self.queue_free()

func _physics_process(delta):
	
	
	if Global.sucking == true:
		freeze = false
	else:
		freeze = true
		

	
	

	
func _on_body_entered(body):
	if Global.sucking == true:
		if body.is_in_group("Character"):
			Global.buttcoins += 1
			print("Buttcoins: " + var_to_str(Global.buttcoins))
			body.animate_pickup()
			self.queue_free()
