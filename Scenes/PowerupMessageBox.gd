extends VBoxContainer

var new_message = preload("res://Scenes/ui/message.tscn")
var active_message

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("notification")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_powerup_message(powerup, texture, powerup_runtime):
	var message = new_message.instantiate()
	message.text = powerup
	message.icon = texture
	message.runtime = powerup_runtime
	add_child(message)
	


func _on_child_entered_tree(node):
	pass
