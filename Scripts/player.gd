extends CharacterBody2D

const BULLET_SCENE = preload("res://Scenes/bullet.tscn")
var yercekimi = 1000
var tepme_gucu = 450
var max_ziplama = 3
var kalan_ziplama = 3
var surtunme = 800
var donme_hizi = 15.0

@onready var kamera = $Camera2D
@onready var gun = $Gun
@onready var sprite = $AnimatedSprite2D
@onready var gun_sound: AudioStreamPlayer2D = $GunSound

@onready var ui_gosterge = $UIGosterge
@onready var mermi_kutusu = $UIGosterge/MermiKutusu
@onready var ceza_bari = $UIGosterge/CezaBari
@onready var olum_sesi = $OlumSesi

var shake_gucu = 0.0
var shake_hizi = 15.0

var oldu_mu = false

var son_atistan_gecen_sure = 1.0 
var ceza_sayaci = 0.0
var atis_kilitli = false
var yerde_atilan_mermi_sayisi = 0

func _ready():
	Global.jeton_sayisi = 0

func _physics_process(delta):
	if oldu_mu:
		return
		
	if atis_kilitli:
		ceza_sayaci -= delta
		if ceza_sayaci <= 0.0:
			atis_kilitli = false
			son_atistan_gecen_sure = 1.0 
	else:
		son_atistan_gecen_sure += delta
		
	if not is_on_floor():
		velocity.y += yercekimi * delta
		velocity.x = move_toward(velocity.x, 0, (surtunme * 0.2) * delta)
		yerde_atilan_mermi_sayisi = 0
	else:
		velocity.x = move_toward(velocity.x, 0, surtunme * delta)
		kalan_ziplama = max_ziplama 
	
	if sprite.animation != "idle":
		sprite.play("idle")

	var fare_konumu = get_global_mouse_position()
	if fare_konumu.x > global_position.x:
		sprite.flip_h = false
		gun.scale.y = 1
	else:
		sprite.flip_h = true
		gun.scale.y = -1
	gun.look_at(fare_konumu)

	for i in range(mermi_kutusu.get_child_count()):
		var mermi_tasiyici_kutu = mermi_kutusu.get_child(i)
		if mermi_tasiyici_kutu.get_child_count() > 0:
			var mermi_animasyonu = mermi_tasiyici_kutu.get_child(0)
			mermi_animasyonu.look_at(fare_konumu)

	if Input.is_action_just_pressed("click") and kalan_ziplama > 0 and not atis_kilitli:
		if is_on_floor() and yerde_atilan_mermi_sayisi >= 3 and son_atistan_gecen_sure < 0.1:
			atis_kilitli = true
			ceza_sayaci = 0.5
		else:
			ates_et_ve_salla(fare_konumu)
			kalan_ziplama -= 1
			son_atistan_gecen_sure = 0.0 
			
			if is_on_floor():
				yerde_atilan_mermi_sayisi += 1

	move_and_slide()

	if is_on_floor():
		var zemin_normali = get_floor_normal()
		var hedef_aci = zemin_normali.angle() + PI/2
		sprite.rotation = lerp_angle(sprite.rotation, hedef_aci, donme_hizi * delta)
	else:
		sprite.rotation = lerp_angle(sprite.rotation, 0, donme_hizi * delta)

func _process(delta):
	if shake_gucu > 0:
		shake_gucu = lerp(shake_gucu, 0.0, shake_hizi * delta)
		kamera.offset = Vector2(randf_range(-shake_gucu, shake_gucu), randf_range(-shake_gucu, shake_gucu))
	else:
		kamera.offset = Vector2.ZERO
		
	if oldu_mu:
		return
		
	if atis_kilitli:
		mermi_kutusu.visible = false
		ceza_bari.visible = true
		ceza_bari.value = ceza_sayaci 
	else:
		ceza_bari.visible = false
		mermi_kutusu.visible = true
		
		for i in range(mermi_kutusu.get_child_count()):
			if i < kalan_ziplama:
				mermi_kutusu.get_child(i).visible = true
			else:
				mermi_kutusu.get_child(i).visible = false

func ates_et_ve_salla(fare_konumu):
	var atis_yonu = global_position.direction_to(fare_konumu)
	velocity = -atis_yonu * tepme_gucu
	
	gun_sound.pitch_scale = randf_range(0.9, 1.1)
	gun_sound.play()
	
	var mermi = BULLET_SCENE.instantiate()
	var namlu_ucu = Vector2(30, 0).rotated(gun.global_rotation)
	mermi.position = gun.global_position + namlu_ucu
	mermi.yon = atis_yonu
	mermi.rotation = atis_yonu.angle()
	get_tree().current_scene.add_child(mermi)
	
	shake_gucu = 20.0


func ol(aninda_yenile = false):
	if oldu_mu: return
	
	oldu_mu = true
	
	Global.olum_sayisi += 1
	get_tree().call_group("labels", "update_death_text", Global.olum_sayisi)
	
	if olum_sesi:
		olum_sesi.play()
		
	if gun: gun.visible = false
	if ui_gosterge: ui_gosterge.visible = false
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	if not aninda_yenile:
		sprite.play("dieslime")
		await sprite.animation_finished
	
	var su_anki_sahne = get_tree().current_scene.scene_file_path
	TransitionLayer.sahne_degistir(su_anki_sahne)

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemies"):
		ol()

func _on_pause_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
