extends Node2D


var dancer_scene = preload("res://Scenes/dancer.tscn")
var trash_suckable = preload("res://Scenes/TrashSuckable.tscn")
var trash_pickable = preload("res://Scenes/TrashPickable.tscn")
var trash_powerup = preload("res://Scenes/ItemScenes/Powerup.tscn")

# UI Components


@onready var active_character = $Player
@onready var new_npc_target : Vector2
@onready var trash_spawn_time : float = 2
# start level parameters
var STARTING_DANCERS = 8
var score
var dancers_spawned = []
var trash_distances = {}
var rng = RandomNumberGenerator.new()
signal character_switch(new_character)
signal trashing(trash_type)
signal game_over

func _ready():
	
	for i in STARTING_DANCERS:
		dancers_spawned.append(spawn_dancer())
	$UI/Inventory.visible = false
	$TrashSpawn.wait_time = trash_spawn_time
		
	self.game_over.connect(Callable(self, "on_game_over",), CONNECT_ONE_SHOT)
		
		
func _process(_delta):
	pass

func _physics_process(delta):
	# Setup the main players pathfinding
	
	if !$Player_Sucker.setup || !$Player_Psychonaut.setup:
		await get_tree().physics_frame
		$Player_Sucker.setup = true
		$Player_Psychonaut.setup = true
	if active_character == $Player :
		var target = $Player.position
		$Player_Sucker.set_movement_target(target)
		$Player_Psychonaut.set_movement_target(target)
	if active_character == $Player_Sucker :
		var target = $Player_Sucker.position
		$Player.set_movement_target(target)
		$Player_Psychonaut.set_movement_target(target)
	if active_character == $Player_Psychonaut :
		var target = $Player_Psychonaut.position
		$Player.set_movement_target(target)
		$Player_Sucker.set_movement_target(target)
	
	
func _unhandled_input(event):
	if event.is_action_released("Inventory"):
		if $UI/Inventory.opened == false:
			$UI/Inventory.open_inventory()
			print("inventory opened")
			return
		else:
			$UI/Inventory.close_inventory()
			print("inventory closed")
			return


		#switch active character
	if event.is_action_released("Switch"):
		if active_character == $Player :
			active_character = $Player_Sucker
			Global.active_character = "Sucker"
			print(Global.active_character)
			emit_signal("character_switch", active_character)
			return
		if active_character == $Player_Sucker :
			active_character = $Player_Psychonaut
			Global.active_character = "Psychonaut"
			print(Global.active_character)
			emit_signal("character_switch", active_character)
			return
		if active_character == $Player_Psychonaut :
			active_character = $Player
			Global.active_character = "Picker"
			print(Global.active_character)
			emit_signal("character_switch", active_character)
			return
	

		



func spawn_dancer():
	var dancer_instance = dancer_scene.instantiate()
	add_child(dancer_instance)
	dancer_instance.movement_target = dancer_instance.random_location()
	return dancer_instance.name
	
func _on_trash_spawn_timeout():
	var selected_dancer = randi() % dancers_spawned.size()
	var dropper = find_child(dancers_spawned[selected_dancer], false, false) 
	if dropper.empathy < dropper.max_empathy:
		var trash_type = trash_roulette()
		spawn_trash(dropper, trash_type)
		self.trashing.connect(Callable(dropper, "on_trashing",), CONNECT_ONE_SHOT)
		emit_signal("trashing", trash_type)


func trash_roulette():
	var trash_type : PackedScene
	var number = randi_range(0, 2)
	if number == 0:
		trash_type = trash_suckable
	if number == 1:
		trash_type = trash_pickable
	if number == 2:
		trash_type = trash_powerup
	return trash_type


	
func spawn_trash(dancer_node: Node, trash_type: PackedScene):
	var x = dancer_node.position.x
	var y = dancer_node.position.y
	var trash_child = trash_type.instantiate()
	var trash_position_offset_x = rng.randi_range(-10, 10)
	var trash_position_offset_y = rng.randi_range(-20, 10)
	trash_child.position = Vector2(x - trash_position_offset_x, y - trash_position_offset_y)
	if trash_type == trash_pickable:
		var selected_loot = select_loot()
		trash_child.loot =  selected_loot
	add_child(trash_child)
	
func select_loot():
	var dir = DirAccess.open("res://Scenes/ItemScenes/LootItems/")
	if dir:
		var all_files = dir.get_files()
		var random = randi_range(0, all_files.size()-1)
		var file = all_files[random]
		var path = "res://Scenes/ItemScenes/LootItems/" + file
		return path
			
				
	else:
		print("An error occurred when trying to access the path.")


# Reccursively gets all children in the tree
# NOTE: Needs to be supplied with atleast one node to begin.
func get_all_children(node) -> Array:
	var nodes : Array = []
	
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
			
	return nodes

# npc pathfind target signal from dancer_target
func _on_target_position_changed():
	new_npc_target = $dancer_target.position
	

#MORAL METER CALCULATOR
func _on_moral_timer_timeout():
	var moral = Global.moral
	var divider = Global.moral_drain_divider
	var wait_time = $MoralTimer.wait_time
	var trash_amount : int
	var nodes =  get_children()
	
	for node in nodes:
		if node.is_in_group("trash"):
			trash_amount += 1
	moral -= (trash_amount / divider) * wait_time
	if moral <= 0:
		moral = 0
		emit_signal("game_over")
	Global.moral = moral
	Global.trash = trash_amount
	
func on_game_over():
	print("GAME OVER!")

