extends AnimatedSprite2D

func _ready():
	
	play("patlama") 
	animation_finished.connect(queue_free)
