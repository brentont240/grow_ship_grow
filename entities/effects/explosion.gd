extends GPUParticles2D

func _ready():
	set_emitting(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !emitting and $ExplosionSoundEffect.finished:
		queue_free()
