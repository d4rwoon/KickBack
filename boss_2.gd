extends CharacterBody2D

@export var boss_mermisi_sahnesi: PackedScene 
@export var nisan_alma_ofseti: float = 15.0 

@onready var animated_sprite = $AnimatedSprite2D
@onready var gun_sprite = $Gun      
@onready var muzzle = $Gun/Muzzle    

var can = 20 # Boss olduğu için canı yüksek              
var yercekimi = 1500
var is_dead = false 
var oyuncu = null 
var ekranda_mi = false

# --- BOSS AŞAMA SİSTEMİ ---
var ates_edebilir = true
var asama = "normal" # Boss'un şu anki saldırı tipi
var normal_ates_sayaci = 0 # Kaç kere normal sıktığını sayar

func _ready():
	add_to_group("enemies") 
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")
		
	# Oyuncuyu buluyoruz
	oyuncu = get_tree().get_root().find_child("Player", true, false)

func _physics_process(delta):
	if is_dead:
		if gun_sprite:
			gun_sprite.visible = false
		return 

	# Yerçekimi
	if not is_on_floor():
		velocity.y += yercekimi * delta
	move_and_slide()

	# Oyuncu hayattaysa ve sahnedeyse işlemleri yap
	if is_instance_valid(oyuncu):
		var nisan_alma_noktasi = oyuncu.global_position + Vector2(0, nisan_alma_ofseti)
		var hedef_yonu = (nisan_alma_noktasi - global_position).normalized()
		
		# Boss'un yüzünü oyuncuya dönmesi
		if hedef_yonu.x != 0:
			animated_sprite.flip_h = hedef_yonu.x > 0

		# Silahı oyuncuya döndürme
		if gun_sprite and ekranda_mi:
			gun_sprite.rotation = hedef_yonu.angle()
			if hedef_yonu.x < 0:
				gun_sprite.scale.y = -1
			else:
				gun_sprite.scale.y = 1

		# --- AŞAMAYA GÖRE ATEŞ ETME ---
		if ekranda_mi and ates_edebilir:
			if asama == "normal":
				normal_ates_et(hedef_yonu)
			elif asama == "taramali":
				taramali_ates_et(hedef_yonu)


# --- 1. AŞAMA: NORMAL ATEŞ ---
func normal_ates_et(hedef_yonu):
	ates_edebilir = false 
	mermi_olustur(hedef_yonu)
	normal_ates_sayaci += 1
	
	# Normal mermi arası bekleme (1.5 saniye)
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree() or is_dead: return # Boss öldüyse durdur
	
	# Eğer 2 kere sıktıysa taramalı faza geç
	if normal_ates_sayaci >= 2:
		normal_ates_sayaci = 0
		asama = "taramali"
		# Taramalıya geçmeden önce tehditkar bir 1 saniyelik duraksama
		await get_tree().create_timer(1.0).timeout 
		if not is_inside_tree() or is_dead: return
		
	ates_edebilir = true


# --- 2. AŞAMA: TARAMALI ATEŞ ---
func taramali_ates_et(baslangic_yonu):
	ates_edebilir = false
	
	# 5 kere çok hızlı ateş etmesi için döngü (for loop) kuruyoruz
	for i in range(5):
		if is_dead or not is_instance_valid(oyuncu): break 
		
		# Mermiler atılırken oyuncu hareket ediyorsa namlu onu takip etsin diye yönü güncelliyoruz
		var guncel_nisan = oyuncu.global_position + Vector2(0, nisan_alma_ofseti)
		var guncel_yon = (guncel_nisan - global_position).normalized()
		
		mermi_olustur(guncel_yon)
		
		# Taramalı mermiler arası bekleme süresi (0.2 saniye - çok hızlı!)
		await get_tree().create_timer(0.2).timeout
		if not is_inside_tree() or is_dead: return
		
	# Taramalı bittikten sonra Boss yorulur, 2 saniye bekler ve başa döner
	asama = "normal"
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree() or is_dead: return
	
	ates_edebilir = true


# --- MERMİYİ SAHNEYE ÇIKARAN ORTAK FONKSİYON ---
func mermi_olustur(yon):
	if animated_sprite.sprite_frames.has_animation("shoot"):
		animated_sprite.play("shoot") 
		
	if boss_mermisi_sahnesi and muzzle:
		var mermi = boss_mermisi_sahnesi.instantiate()
		get_parent().add_child(mermi)
		mermi.global_position = muzzle.global_position
		
		if mermi.has_method("yonu_ayarla"):
			mermi.yonu_ayarla(yon)
			
	# Ateş animasyonundan sonra tekrar bekleme (idle) animasyonuna dön
	await get_tree().create_timer(0.5).timeout
	if not is_dead and is_inside_tree() and animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")


# --- SİNYALLER VE HASAR (Eski kodunla aynı) ---
func _on_visible_on_screen_notifier_2d_screen_entered():
	ekranda_mi = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	ekranda_mi = false

func _on_hurt_box_body_entered(body):
	if not is_dead and body.name == "Player":
		if body.has_method("ol"):
			body.ol()

func canavar_oldu():
	if is_dead: return 
	can -= 1 
	if can > 0:
		oynat_hasar_efekti() 
		return 
		
	is_dead = true
	if has_node("Gun"): $Gun.visible = false
	if is_in_group("enemies"): remove_from_group("enemies")
	if has_node("CollisionShape2D"): $CollisionShape2D.set_deferred("disabled", true)
	
	if has_node("HurtBox"):
		$HurtBox.set_deferred("monitoring", false)
		$HurtBox.set_deferred("monitorable", false)
		if has_node("HurtBox/CollisionShape2D"):
			$HurtBox/CollisionShape2D.set_deferred("disabled", true)
			
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.self_modulate = Color(1, 1, 1) 
		$AnimatedSprite2D.play("die") 

func oynat_hasar_efekti():
	animated_sprite.self_modulate = Color(10, 0, 0) 
	await get_tree().create_timer(0.1).timeout
	if not is_dead and has_node("AnimatedSprite2D"):
		animated_sprite.self_modulate = Color(1, 1, 1) 

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "die":
		queue_free()
