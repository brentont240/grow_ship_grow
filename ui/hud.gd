extends Control

@onready var growth = $Growth:
	set(value):
		growth.text = "Growth: " + str(value)	
		
var uilife_scene = preload("res://ui/uiLife.tscn")
@onready var lives = $Lives

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
