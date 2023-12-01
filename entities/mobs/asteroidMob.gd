extends Area2D

@onready var mob_component = $MobComponent
@onready var hit_flash_animation_player = $HitFlashAnimationPlayer
var hit_animation = "hit_flash"

signal create_small_asteroids(pos)

# Called when the node enters the scene tree for the first time.
var curr_scale : float

var is_large_asteroid = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_large_asteroid:
		mob_component.scale_min = 0.4
		mob_component.scale_max = 0.5
	mob_component.init_mob()

func _physics_process(delta):
	mob_component.move_mob(rotation, delta)

func _on_health_component_is_dead():
	if is_large_asteroid:
		emit_signal("create_small_asteroids", global_position)
