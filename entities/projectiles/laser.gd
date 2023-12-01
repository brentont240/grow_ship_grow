extends Area2D

@onready var projectile_component = $ProjectileComponent

# add a timed life to bullets?
# await get_tree().create_timer(0.25).timeout

func _physics_process(delta):
	projectile_component.move_projectile(rotation, delta)
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	# Delete the lasers when they leave the screen
	queue_free()

func _on_area_entered(area):
	projectile_component.handle_collision(area)
