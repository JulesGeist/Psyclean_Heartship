# SOURCE: https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7

extends Node2D

@onready var items

func _ready():
	items = read_from_JSON("res://Assets/json/items.json")
	for key in items.keys():
		items[key]["key"] = key

func read_from_JSON(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if FileAccess.file_exists(path):
		var json_as_text = FileAccess.get_file_as_string(path)
		var data = JSON.parse_string(json_as_text)
		file.close()
		return data
	else:
		printerr("Invalid path given")

func get_item_by_key(key):
	if items and items.has(key):
		return items[key].duplicate(true)
	else:
		printerr("Item not found in inventory")
