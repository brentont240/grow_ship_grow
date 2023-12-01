extends CanvasLayer

# This script preloads all the particle effects to prevent lag in game

var shipFire = preload("res://assets/materials/shipFire.tres")
var explosion = preload("res://assets/materials/explosion.tres")
var grow = preload("res://assets/materials/growEffect.tres")
var star_field_back = preload("res://assets/materials/starFieldParticlesBack.tres")
var star_field_middle = preload("res://assets/materials/starFieldParticlesMiddle.tres")
var star_field_front = preload("res://assets/materials/starFieldParticlesFront.tres")

# Make sure to all all particles to this array
var materials = [
	shipFire,
	explosion,
	grow,
	star_field_back,
	star_field_middle,
	star_field_front
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	for material in materials:
		var particles_instance = GPUParticles2D.new()
		particles_instance.set_process_material(material)
		particles_instance.set_one_shot(true)
		particles_instance.set_modulate(Color(1, 1, 1,0 ))
		particles_instance.set_emitting(true)
		self.add_child(particles_instance)
