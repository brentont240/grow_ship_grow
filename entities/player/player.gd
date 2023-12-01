extends CharacterBody2D

signal laser_shot(laser)
signal has_grown()
signal add_life()

@export var acceleration := 10.0
# Was 400.0
@export var max_speed := 350.0
@export var angular_speed = PI
@export var fire_trail_gravity = 90.0

var kill_counter = 0
var growth = 0
var growth_scale = .1

var curr_scale : float

@onready var muzzle = $Muzzle
@onready var left_muzzle = $LeftMuzzle
@onready var right_muzzle = $RightMuzzle
@onready var spread_muzzle_1 = $SpreadMuzzle1
@onready var spread_muzzle_2 = $SpreadMuzzle2
@onready var spread_muzzle_3 = $SpreadMuzzle3
@onready var fire_trail = $FireTrail
@onready var hitbox_component = $HitboxComponent
@onready var health_component = $HealthComponent

var laser_scene = preload("res://entities/projectiles/laser.tscn")
var dual_laser_scene = preload("res://entities/projectiles/dualLaser.tscn")
var spread_laser_scene = preload("res://entities/projectiles/spreadLaser.tscn")
var missile_scene = preload("res://entities/projectiles/missile.tscn")
var growth_effect = preload("res://entities/effects/growEffect.tscn")

@onready var hit_flash_animation_player = $HitFlashAnimationPlayer
var hit_animation = "hit_flash"

# The shoot cooldown that says when the player can shoot again
var shoot_cd = false

# The hit cooldown that says when the player can be hit again
var hit_cd = false

var screen_size # Size of the game window.

# 0 = standard, 1 = dual, 2 = spread, 3 = missile
var weapon_type = 0
var num_projectiles = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	curr_scale = scale.x
# Make it so that the firetrail looks better!

func _process(delta):
	# change timer time based on projectile type
	var shoot_delay
	match weapon_type:
		0:
			shoot_delay = 0.45
		1:
			shoot_delay = 0.60
		2:
			shoot_delay = 0.80
		3:
			shoot_delay = 0.75
	
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(shoot_delay).timeout
			shoot_cd = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_pressed("move_forward"):
		# Accelerate the ship in the rotated direction
		velocity += Vector2.UP.rotated(rotation) * acceleration
		fire_trail.set_emitting(true)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 2.5)
		fire_trail.set_emitting(false)

	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("rotate_left"):
		rotate(-angular_speed * delta)
	
	if Input.is_action_pressed("rotate_right"):
		rotate(angular_speed * delta) 	 

	# Moves the ship
	move_and_slide()
	
	# Makes it so the ship cannot leave the screen
	#position = position.clamp(Vector2.ZERO, screen_size)
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
		
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser():
	match weapon_type:
		1:
			num_projectiles = 2
		2: 
			num_projectiles = 3
		_:
			num_projectiles = 1
			
	for n in num_projectiles:
		var p
		match weapon_type:
			0:
				p = laser_scene.instantiate()
				p.global_position = muzzle.global_position
			1: 
				p = dual_laser_scene.instantiate()
				if n == 0:
					p.global_position = left_muzzle.global_position
				else:
					p.global_position = right_muzzle.global_position
			2:
				p = spread_laser_scene.instantiate()
				if n == 0:
					p.global_position = spread_muzzle_1.global_position
				elif n == 1:
					p.global_position = spread_muzzle_2.global_position
				else:
					p.global_position = spread_muzzle_3.global_position
			3: 
				p = missile_scene.instantiate()
				p.global_position = muzzle.global_position

		p.rotation = rotation
		# Scale the size of the bullets with the size of the ship
		p.scale.x += (growth_scale * growth)
		p.scale.y += (growth_scale * growth)
		emit_signal("laser_shot", p)	
	
func grow():
	growth += 1
	
	# Increase the scale of the ship
	scale.x += (growth_scale * growth)
	scale.y += (growth_scale * growth)
	
	curr_scale = scale.x
	
	# Add a grow effect to signify growth
	var effect = growth_effect.instantiate()
	effect.global_position = global_position
	effect.scale.x += growth
	effect.scale.y += growth
	get_tree().current_scene.add_child(effect)
	emit_signal("has_grown")

func add_kill():
	kill_counter += 1
	# print(kill_counter)
	if kill_counter > 2:
		# Give a 1/3 chance to grow after getting 2 or more kills
		var roll = randi_range(1,3)
		if roll == 3:
			grow()
			kill_counter = 0

# Damage the player if they hit a mob
func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent:
		if !hit_cd:
			hit_cd = true
			hitbox_component.hit(1)
			await get_tree().create_timer(0.2).timeout
			hit_cd = false	
	elif area is PowerUp:
		match area.power_up_type:
			4: 
				if health_component.health <= 3:
					health_component.health += 1
					emit_signal("add_life")
			_:
				weapon_type = area.power_up_type
		area.queue_free()
