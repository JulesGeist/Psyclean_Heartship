extends TextureProgressBar

var battery : float
var max_battery : float

# Called when the node enters the scene tree for the first time.
func _ready():
	
	await get_tree().physics_frame
	battery = $"../../../../Player_Sucker".battery
	max_battery = Active.suck_time
	max_value = max_battery

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	await get_tree().physics_frame
	battery = $"../../../../Player_Sucker".battery
	value = battery
	
	
