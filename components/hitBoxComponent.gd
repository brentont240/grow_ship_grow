extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent
var curr_scale
var curr_position 
var animation_source 
var animation 

func hit(damage):
	if health_component:
		curr_scale = get_parent().curr_scale
		curr_position = get_parent().global_position
		animation_source = get_parent().hit_flash_animation_player
		animation = get_parent().hit_animation
		health_component.hit(damage, curr_scale, curr_position, animation_source, animation)
