extends Area2D

@onready var mob_component = $MobComponent
@onready var hit_flash_animation_player = $HitFlashAnimationPlayer
var hit_animation = "hit_flash"

var curr_scale : float

# Called when the node enters the scene tree for the first time.
func _ready():
	mob_component.init_mob()

func _physics_process(delta):
	mob_component.move_mob(rotation, delta)
