extends Area2D

@onready var projectile_component = $ProjectileComponent

var target = null

func _physics_process(delta):
	# Home into a target if there is one
	if target:
		# Look at the target
		look_at(target.global_position)
		# Apply the proper rotation to the missile
		rotation += PI/2
	projectile_component.move_projectile(rotation, delta)
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	# Delete the lasers when they leave the screen
	queue_free()

func _on_area_entered(area):
	projectile_component.handle_collision(area)
	
func _on_homing_area_area_entered(area):
		if area is HitboxComponent and area.get_parent().name != "Player":
			target = area
