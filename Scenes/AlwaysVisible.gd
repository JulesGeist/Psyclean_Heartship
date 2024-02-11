extends Control

@onready var portrait_picker = $PickerActive/PickerPortrait
@onready var portrait_sucker = $SuckerActive/SuckerPortrait
@onready var portrait_psycho = $PsychonautActive/PsychoPortrait


 
func _on_world_character_switch(new_character):
	if Global.active_character == "Picker":
		$PickerActive.button_pressed = true
		$SuckerActive.button_pressed = false
		$PsychonautActive.button_pressed = false
		portrait_picker.play("yes")
		
		return
	elif Global.active_character == "Sucker":
		$PickerActive.button_pressed = false
		$SuckerActive.button_pressed = true
		$PsychonautActive.button_pressed = false
		portrait_sucker.play("yes")
		
		return
	elif Global.active_character == "Psychonaut":
		$PickerActive.button_pressed = false
		$SuckerActive.button_pressed = false
		$PsychonautActive.button_pressed = true
		portrait_psycho.play("yes")
		return


func _on_picker_active_pressed():
	Global.active_character = "Picker"
	_on_world_character_switch("Picker")

func _on_sucker_active_pressed():
		Global.active_character = "Sucker"
		_on_world_character_switch("Sucker")
		

func _on_psychonaut_active_pressed():
		Global.active_character = "Psychonaut"
		_on_world_character_switch("Psychonaut")
