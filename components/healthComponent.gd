extends Node2D
class_name HealthComponent

signal is_hit
signal is_dead

# Make sure to change this for each enemy type
@export var MAX_HEALTH = 3
var health : float

var explosion_effect = preload("res://entities/effects/explosion.tscn")

func _ready():
	health = MAX_HEALTH

func hit(damage, scale, position, animation_source, animation):
	emit_signal("is_hit")
	health -= damage
	if animation_source:
		animation_source.play(animation)
	$HitSoundEffect.play()
	
	if health <= 0:
		emit_signal("is_dead")
		var effect = explosion_effect.instantiate()
		effect.global_position = position
		effect.scale.x = scale
		effect.scale.y = scale
		get_tree().current_scene.add_child(effect)
		get_parent().queue_free()

func get_health():
	return health
