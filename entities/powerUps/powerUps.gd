class_name PowerUp extends Area2D

# 0 = standard, 1 = dual, 2 = spread, 3 = missile, 4 = extra life
var power_up_type : int

@onready var sprite = $Sprite2D

# Make it so the power up blinks before dying

func _ready():
	match power_up_type:
		1:
			sprite.texture = load("res://assets/art/powerUp1.png")
		2:
			sprite.texture = load("res://assets/art/powerUp2.png")
		3:
			sprite.texture = load("res://assets/art/powerUp3.png")	
		4:
			sprite.texture = load("res://assets/art/powerUp4.png")	

func _on_life_span_timeout():
	queue_free()
