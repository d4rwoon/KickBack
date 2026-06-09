extends CharacterBody2D

@export var bolunme_seviyesi: int = 2 # 2: Büyük, 1: Orta, 0: Küçük (Artık bölünmez)

var can: int = 9 # Varsayılan canımız
var hiz = 100.0
var yon = -1 # Başlangıç yönü
var yercekimi = 1500
var is_dead = false 

func _ready():
	add_to_group("enemies") 
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
		
	# DOĞDUĞUNDA 0.4 SANİYE BOYUNCA OYUNCUYA ZARAR VEREMEZ (Bunu şimdilik tutuyorum, ileride ayarlarsın)
	if has_node("HurtBox"):
		$HurtBox.set_deferred("monitoring", false)
		
	# BÖLÜNME SEVİYESİNE GÖRE CAN, BOYUT VE HIZ AYARI
	if bolunme_seviyesi == 2:
		scale = Vector2(4.0, 4.0) # EN BÜYÜK HALİ 
		can = 9 
		hiz = 50.0 # İLK HALİNİN HIZI (Çok yavaş ve hantal)
	elif bolunme_seviyesi == 1:
		scale = Vector2(2.0, 2.0) # Orta boy 
		can = 3 
		hiz = 110.0 # İKİNCİ HALİNİN HIZI (Normal hız)
	elif bolunme_seviyesi == 0:
		scale = Vector2(1.0, 1.0) # Küçük boy 
		can = 1 
		hiz = 180.0 # ÜÇÜNCÜ HALİNİN HIZI (Çok hızlı, koşan ufaklıklar)

	# 0.4 saniye bekle ve sonra HurtBox'ı (hasar vermeyi) tekrar aç
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
		
	# Mermi yediğinde canı 1 azalsın
	can -= 1
	
	# KIRMIZI PARLAMA EFEKTİ
	if has_node("AnimatedSprite2D"):
		var tween = create_tween()
		$AnimatedSprite2D.modulate = Color(1, 0, 0) # Anında tam kırmızı yap
		tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1), 0.15) # 0.15 saniyede normale döndür
	
	# Eğer canı hala 0'dan büyükse ölüm işlemlerine geçme, fonksiyondan çık
	if can > 0:
		return
		
	# Canı 0 veya altına düştüyse ölüm işlemleri başlasın
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
			
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("die")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "die":
		if bolunme_seviyesi > 0:
			parcalan()
			
		queue_free()

func parcalan():
	var asil_sahne = load(scene_file_path)
	
	for i in range(2):
		var yeni_boss = asil_sahne.instantiate()
		yeni_boss.bolunme_seviyesi = bolunme_seviyesi - 1
		
		var uzaklik = 60 if bolunme_seviyesi == 2 else 30
		var offset_x = uzaklik if i == 0 else -uzaklik
		
		yeni_boss.global_position = global_position + Vector2(offset_x, -20)
		
		yeni_boss.yon = 1 if i == 0 else -1
		
		get_parent().call_deferred("add_child", yeni_boss)

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
