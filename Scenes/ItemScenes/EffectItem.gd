extends BaseItem


class_name EffectItem

@export var tool_type = "" # Shooter,Sucker 
@export var slot_effect : Dictionary # if item is in a slot, change things as long as equipped
@export var action_effect : Dictionary # oneshot-action on right-click
@export var use_contained_items : bool = false # on right-click, it will use the action of the first item in its inventory.
@export var single_use : bool = true
@export var target_object = ""
@export var element = ""
var effect_active : bool = false


	
func _unhandled_input(event):
	if event.is_action_released("ItemAction"):
		if  Rect2(Vector2(), size).has_point(get_local_mouse_position()):
			activate_action_effect()

	
func activate_action_effect():
	if use_contained_items:
		if inventory.get_child_count() > 0:
			var contained_item = inventory.get_child(1)
			if contained_item.is_in_group("EffectItem"):
				contained_item.activate_action_effect()
	if single_use:
		for key in action_effect:
			pass  #action effects are not ready yet.
		queue_free()



func _on_tree_entered():
	var parent_item = $"../.."
	if parent_item.is_in_group("EffectItem"):
		for effect in slot_effect:
			if effect is int or effect is float:
				if parent_item.slot_effect.has(effect):
					parent_item.slot_effect[effect].value += slot_effect[effect].value
			if effect is String:
				parent_item.slot_effect[effect].append(slot_effect[effect].value)
				print("slot_effect updated: ", effect)
				return
	
	


func _on_tree_exiting():
	var parent_item = $"../.."
	if parent_item.is_in_group("EffectItem"):
		for effect in slot_effect:
			if parent_item.slot_effect.has(effect):
				if effect is int or effect is float:
					parent_item.slot_effect[effect].value -= slot_effect[effect].value
				if effect is String:
					parent_item.slot_effect[effect].keys.erase(slot_effect[effect].value)
					print("slot_effect erased: " , effect)
					return


