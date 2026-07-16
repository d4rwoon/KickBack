extends CharacterBody2D

@export var bolunme_seviyesi: int = 3

@onready var hasar_alma_sesi = $MobHasarAlmaSesi
@onready var olum_sesi = $OlumSesi

var can: int = 30
var hiz = 40.0
var yon = -1
var yercekimi = 1500
var is_dead = false

func _ready():
	add_to_group("enemies")
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
		
	if has_node("HurtBox"):
		$HurtBox.set_deferred("monitoring", false)
		
	if bolunme_seviyesi == 3:
		scale = Vector2(4.5, 4.5)
		can = 30
		hiz = 40.0
	elif bolunme_seviyesi == 2:
		scale = Vector2(3.0, 3.0)
		can = 10
		hiz = 80.0
	elif bolunme_seviyesi == 1:
		scale = Vector2(1.5, 1.5)
		can = 3
		hiz = 140.0
	elif bolunme_seviyesi == 0:
		scale = Vector2(0.7, 0.7)
		can = 1
		hiz = 250.0

	await get_tree().create_timer(0.4).timeout
	if not is_dead and has_node("HurtBox"):
		$HurtBox.set_deferred("monitoring", true)

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
		
	can -= 1
	
	if hasar_alma_sesi:
		hasar_alma_sesi.play()
	
	if has_node("AnimatedSprite2D"):
		var tween = create_tween()
		$AnimatedSprite2D.modulate = Color(1, 0, 0)
		tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1), 0.15)
	
	if can > 0:
		return
		
	is_dead = true
	
	if olum_sesi:
		olum_sesi.play()
	
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
			
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("die")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "die":
		if bolunme_seviyesi > 0:
			parcalan()
			
		if olum_sesi and olum_sesi.playing:
			await olum_sesi.finished
			
		queue_free()

func parcalan():
	var asil_sahne = load(scene_file_path)
	
	for i in range(2):
		var yeni_boss = asil_sahne.instantiate()
		yeni_boss.bolunme_seviyesi = bolunme_seviyesi - 1
		
		var uzaklik = 20
		if bolunme_seviyesi == 3:
			uzaklik = 70
		elif bolunme_seviyesi == 2:
			uzaklik = 45
			
		var offset_x = uzaklik if i == 0 else -uzaklik
		
		yeni_boss.global_position = global_position + Vector2(offset_x, -20)
		
		yeni_boss.yon = 1 if i == 0 else -1
		
		get_parent().call_deferred("add_child", yeni_boss)

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
