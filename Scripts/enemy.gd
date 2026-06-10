extends CharacterBody2D

@onready var olum_sesi = $OlumSesi

var hiz = 100.0
var yon = -1
var yercekimi = 1500
var is_dead = false

func _ready():
	add_to_group("enemies")
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += yercekimi * delta

	if is_on_wall():
		yon *= -1

	$AnimatedSprite2D.flip_h = yon > 0

	velocity.x = yon * hiz
	move_and_slide()

func _on_hurt_box_body_entered(body):
	if not is_dead and body.has_method("ol") and not body.is_in_group("enemies"):
		body.ol()

func canavar_oldu():
	if is_dead:
		return
	is_dead = true

	velocity = Vector2.ZERO

	if is_in_group("enemies"):
		remove_from_group("enemies")

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

	if has_node("HurtBox"):
		$HurtBox.set_deferred("monitoring", false)
		$HurtBox.set_deferred("monitorable", false)

		if $HurtBox.has_node("CollisionShape2D"):
			$HurtBox/CollisionShape2D.set_deferred("disabled", true)
			
	if olum_sesi:
		olum_sesi.play()

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("die")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "die":
		if olum_sesi and olum_sesi.playing:
			await olum_sesi.finished
		queue_free()

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
