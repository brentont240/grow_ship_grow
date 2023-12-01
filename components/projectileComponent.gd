extends Node2D
class_name ProjectileComponent

var movement_vector = Vector2(0, -1)

@export var speed : float 
@export var damage : float
@export var is_player_projectile : bool

# the lifespan of the bullet
@export var bullet_life : float

func move_projectile(rot, delta):
	get_parent().global_position += movement_vector.rotated(rot) * speed * delta
	
	if bullet_life:
		await get_tree().create_timer(bullet_life).timeout
		get_parent().queue_free()

func handle_collision(area):
	if area is HitboxComponent and area.get_parent().name != "Player" and is_player_projectile:
		area.hit(damage)
		get_parent().queue_free()
	elif area is HitboxComponent and area.get_parent().name == "Player" and !is_player_projectile:
		area.hit(damage)
		get_parent().queue_free()
