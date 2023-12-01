extends Area2D

signal enemy_laser_shot(laser)

@onready var mob_component = $MobComponent
@onready var hit_flash_animation_player = $HitFlashAnimationPlayer

var hit_animation = "hit_flash"

var laser_scene = preload("res://entities/projectiles/enemyLaser.tscn")

var curr_scale : float

# Called when the node enters the scene tree for the first time.
func _ready():
	mob_component.init_mob()

func _physics_process(delta):
	mob_component.move_mob(rotation, delta)

func _on_shoot_timer_timeout():
	var num_lasers = 4
	var angle = PI/2
	for i in num_lasers:
		var laser = laser_scene.instantiate()
		laser.rotation =  rotation + (angle * i)
		laser.global_position = global_position
		# Scale the size of the bullets with the size of the ship
		laser.scale.x = curr_scale
		laser.scale.y = curr_scale
		emit_signal("enemy_laser_shot", laser)	
