extends Area2D

var hiz = 400
var yon = Vector2.ZERO


@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	if animated_sprite:
		animated_sprite.play("bullet")

func yonu_ayarla(gelen_yon_vektoru):
	yon = gelen_yon_vektoru
	rotation = yon.angle()

func _physics_process(delta):
	position += yon * hiz * delta

func _on_body_entered(body):
	if body.name.begins_with("Enemy") or body.is_in_group("enemies"):
		return
	
	if body.has_method("ol"):
		body.ol()
		queue_free() 
		return

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
