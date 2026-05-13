extends Area2D

var hiz = 1000
var yon = Vector2.ZERO


@export var vurus_efekti_sahnesi: PackedScene


func _ready():
	$AnimatedSprite2D.play("bullet")

func _physics_process(delta):
	position += yon * hiz * delta

func _on_body_entered(body):
	if body.name == "Player":
		return
	_efekti_olustur()
	
	
	if body.name.begins_with("Enemy") or body.is_in_group("enemies"):
		if body.has_method("canavar_oldu"):
			body.canavar_oldu() 
		else:
			body.queue_free() 
		queue_free() 
		return

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _efekti_olustur():
	if vurus_efekti_sahnesi:
		var efekt = vurus_efekti_sahnesi.instantiate()
		efekt.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", efekt)
