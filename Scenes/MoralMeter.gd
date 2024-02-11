extends TextureProgressBar

var moral
var max_moral



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	await get_tree().physics_frame
	set_size(Vector2(Global.max_moral/3,16))
	max_value = Global.max_moral
	value = Global.moral
	$Percent.clear()
	var percent = (Global.moral / Global.max_moral) * 100
	percent = round(percent)
	$Percent.add_text(str(percent))
	$Percent.append_text("%")
	
