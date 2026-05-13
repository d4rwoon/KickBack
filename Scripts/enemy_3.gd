extends CharacterBody2D


@export var mermi_sahnesi: PackedScene 
@export var ates_hizi = 1.5        
@export var nisan_alma_ofseti: float = 15.0 


@onready var animated_sprite = $AnimatedSprite2D
@onready var gun_sprite = $Gun      
@onready var muzzle = $Gun/Muzzle    

var ates_edebilir = true   
var can = 3                
var yercekimi = 1500
var is_dead = false 
var oyuncu = null 


var ekranda_mi = false 

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

	
	if not is_on_floor():
		velocity.y += yercekimi * delta
	move_and_slide()

	
	if oyuncu != null:
		var nisan_alma_noktasi = oyuncu.global_position + Vector2(0, nisan_alma_ofseti)
		var hedef_yonu = (nisan_alma_noktasi - global_position).normalized()
		if hedef_yonu.x != 0:
			animated_sprite.flip_h = hedef_yonu.x > 0

		
		if gun_sprite and ekranda_mi:
			gun_sprite.rotation = hedef_yonu.angle()
			
			if hedef_yonu.x < 0:
				gun_sprite.scale.y = -1
			else:
				gun_sprite.scale.y = 1

		
		if ekranda_mi and ates_edebilir:
			ates_et(hedef_yonu)

func ates_et(hedef_yonu):
	ates_edebilir = false 
	
	
	if animated_sprite.sprite_frames.has_animation("shoot"):
		animated_sprite.play("shoot") 

	
	if mermi_sahnesi and muzzle:
		var mermi = mermi_sahnesi.instantiate()
		get_parent().add_child(mermi)
		
		
		mermi.global_position = muzzle.global_position
		
		
		if mermi.has_method("yonu_ayarla"):
			mermi.yonu_ayarla(hedef_yonu)

	
	await get_tree().create_timer(ates_hizi).timeout
	ates_edebilir = true 
	
	if not is_dead and animated_sprite.sprite_frames.has_animation("idle"):
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
	if is_dead:
		return 
		
	
	can -= 1 
	
	
	if can > 0:
		
		oynat_hasar_efekti() 
		return 
		
	
	is_dead = true
	
	
	if has_node("Gun"):
		$Gun.visible = false
	
	
	if is_in_group("enemies"):
		remove_from_group("enemies")
		
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	
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
