extends CharacterBody2D

@export var boss_mermisi_sahnesi: PackedScene
@export var nisan_alma_ofseti: float = 15.0
@export var hareket_hizi: float = 60.0
@export var icinden_cikacak_sahne: PackedScene
@export var icinden_cikacak_coin: PackedScene
@export var portalin_level_numarasi: int = 5

@onready var animated_sprite = $AnimatedSprite2D
@onready var gun_sprite = $Gun
@onready var muzzle = $Gun/Muzzle
@onready var olum_sesi = $OlumSesi
@onready var taramali_sesi = $TaramaliSesi
@onready var normal_ates_sesi = $Boss2Ates

var can = 20
var yercekimi = 1500
var is_dead = false
var oyuncu = null
var ekranda_mi = false

var ates_edebilir = true
var asama = "normal"
var normal_ates_sayaci = 0

func _ready():
	add_to_group("enemies")
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")
		
	oyuncu = get_tree().get_root().find_child("Player", true, false)

func _physics_process(delta):
	if is_dead:
		if gun_sprite:
			gun_sprite.visible = false
		return

	if not is_dead and asama == "hareket" and is_instance_valid(oyuncu):
		var oyuncu_yonu = (oyuncu.global_position - global_position).normalized()
		velocity.x = oyuncu_yonu.x * hareket_hizi
		
		if animated_sprite.sprite_frames.has_animation("walk") and animated_sprite.animation != "walk":
			animated_sprite.play("walk")
			
	else:
		velocity.x = 0
		
		if not is_dead and animated_sprite.animation == "walk" and animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

	if not is_on_floor():
		velocity.y += yercekimi * delta
		
	move_and_slide()

	if is_instance_valid(oyuncu):
		var nisan_alma_noktasi = oyuncu.global_position + Vector2(0, nisan_alma_ofseti)
		var hedef_yonu = (nisan_alma_noktasi - global_position).normalized()
		
		if hedef_yonu.x != 0:
			animated_sprite.flip_h = hedef_yonu.x < 0

		if gun_sprite and ekranda_mi:
			gun_sprite.rotation = hedef_yonu.angle()
			if hedef_yonu.x < 0:
				gun_sprite.scale.y = -1
			else:
				gun_sprite.scale.y = 1

		if ekranda_mi and ates_edebilir:
			if asama == "normal":
				normal_ates_et(hedef_yonu)
			elif asama == "taramali":
				taramali_ates_et(hedef_yonu)

func normal_ates_et(hedef_yonu):
	ates_edebilir = false
	
	if normal_ates_sesi:
		normal_ates_sesi.play()
		
	mermi_olustur(hedef_yonu)
	normal_ates_sayaci += 1
	
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree() or is_dead: return
	
	if normal_ates_sayaci >= 2:
		normal_ates_sayaci = 0
		asama = "hareket"
		
		await get_tree().create_timer(3.0).timeout
		if not is_inside_tree() or is_dead: return
		
		asama = "taramali"
		
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree() or is_dead: return
		
	ates_edebilir = true

func taramali_ates_et(baslangic_yonu):
	ates_edebilir = false
	
	for i in range(6):
		if is_dead or not is_instance_valid(oyuncu): break
		
		var guncel_nisan = oyuncu.global_position + Vector2(0, nisan_alma_ofseti)
		var guncel_yon = (guncel_nisan - global_position).normalized()
		
		if taramali_sesi:
			taramali_sesi.play()
		
		mermi_olustur(guncel_yon)
		await get_tree().create_timer(0.2).timeout
		if not is_inside_tree() or is_dead: return
		
	asama = "normal"
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree() or is_dead: return
	
	ates_edebilir = true

func mermi_olustur(yon):
	if animated_sprite.sprite_frames.has_animation("shoot"):
		animated_sprite.play("shoot")
		
	if boss_mermisi_sahnesi and muzzle:
		var mermi = boss_mermisi_sahnesi.instantiate()
		get_parent().add_child(mermi)
		mermi.global_position = muzzle.global_position
		
		if mermi.has_method("yonu_ayarla"):
			mermi.yonu_ayarla(yon)
			
	await get_tree().create_timer(0.5).timeout
	if not is_dead and is_inside_tree() and animated_sprite.sprite_frames.has_animation("idle") and asama != "hareket":
		animated_sprite.play("idle")

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
	
	if olum_sesi:
		olum_sesi.play()
		
	asama = "olu"
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

func sahne_dogur():
	if icinden_cikacak_sahne:
		var yeni_obje = icinden_cikacak_sahne.instantiate()
		if "bu_levelin_numarasi" in yeni_obje:
			yeni_obje.bu_levelin_numarasi = portalin_level_numarasi
		get_parent().add_child(yeni_obje)
		yeni_obje.global_position = global_position + Vector2(-40, 0)
		
	if icinden_cikacak_coin:
		var coin_obje = icinden_cikacak_coin.instantiate()
		get_parent().add_child(coin_obje)
		coin_obje.global_position = global_position + Vector2(40, 0)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "die":
		sahne_dogur()
		queue_free()
