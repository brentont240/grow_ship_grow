extends Node

func _ready():
	$Controls.hide()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level1.tscn")


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_controls_button_toggled(toggled_on):
	$Controls.visible = toggled_on
	$Instructions.visible = !toggled_on
