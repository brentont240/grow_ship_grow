extends Node2D

var screen_size

var movement_vector  = Vector2(0, -1)

var speed

@export var health_component : HealthComponent

@export var speed_min : float
@export var speed_max : float

@export var scale_min : float
@export var scale_max : float

# probability of spawing a powerup when killed
@export var drop_probability : int

# 0 = ufo, 1 = asteroid, 2 = ship
@export var mob_type : int

@export var can_change_direction : bool
@export var direction_timer : float
var direction_timer_up = true

signal spawn_powerup(pos)

func _ready():
	health_component.connect("is_dead", roll_spawn_powerup)

func init_mob():
	screen_size = get_viewport_rect().size
	
	# Randomize the size of the mobs
	var mob_scale = randf_range(scale_min, scale_max)
	get_parent().curr_scale = mob_scale
	
	get_parent().scale.x = mob_scale
	get_parent().scale.y = mob_scale
	
	get_parent().rotation = randf_range(0, 2*PI)
	
	# Randomize the speed of the mobs
	speed = randf_range(speed_min, speed_max)

func move_mob(rot, delta):
	get_parent().global_position += movement_vector.rotated(rot) * speed * delta
	
	if get_parent().global_position.y < 0:
		get_parent().global_position.y = screen_size.y
	elif get_parent().global_position.y > screen_size.y:
		get_parent().global_position.y = 0
		
	if get_parent().global_position.x < 0:
		get_parent().global_position.x = screen_size.x
	elif get_parent().global_position.x > screen_size.x:
		get_parent().global_position.x = 0
		
	if can_change_direction:
		if direction_timer_up:
			direction_timer_up = false
			await get_tree().create_timer(direction_timer).timeout
			direction_timer_up = true
			var new_rotation = randf_range(0, 2*PI)
			# get_parent().rotation = lerp(get_parent().rotation, new_rotation, .05)
			get_parent().rotation = new_rotation

func roll_spawn_powerup():
	var roll = randi_range(1, drop_probability)
	if roll == 1:
		emit_signal("spawn_powerup", global_position)
