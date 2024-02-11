extends TextureProgressBar

@onready var text : Array
@onready var text1 : String
@onready var text2 : String
@onready var icon : int
@onready var runtime
var running
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().physics_frame
	
	
	array_to_text(text)
	$Text2.text = text2
	$Icon.frame = icon
	$Text.text = text1
	$Runtime.start(runtime)
	max_value = runtime
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):


	if text1 == "Moral Boost!":
		value = 0
	elif text1 == "Moral filled!":
		value = 0
	else:
		running = $Runtime.time_left
		value = running




func _on_runtime_timeout():
	self.queue_free()

func array_to_text(text_array):
	var array = text_array
	var entry1 = str(array[0])
	var entry2 = str(array[1])
	text1 = entry1
	text2 = entry2
