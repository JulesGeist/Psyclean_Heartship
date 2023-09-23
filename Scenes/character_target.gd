extends Marker2D

func _process(delta):
	position = get_parent().active_character.position
