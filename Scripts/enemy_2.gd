extends CharacterBody2D


var hiz = 150.0
var can = 2              
var is_dead = false 
var takip_basladi = false 
var oyuncu = null 


var zaman = 0.0
var dalga_hizi = 4.0      
var dalga_miktari = 30.0  


func _ready():
	
	add_to_group("enemies") 
	
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
		
	oyuncu = get_tree().get_root().find_child("Player", true, false)


func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO 
		move_and_slide()
		return 

	zaman += delta

	
	if takip_basladi and oyuncu != null:
		var yon_vektoru = (oyuncu.global_position - global_position).normalized()
		if yon_vektoru.x != 0:
			$AnimatedSprite2D.flip_h = yon_vektoru.x > 0
		
		
		velocity = yon_vektoru * hiz
		
		velocity.y += sin(zaman * dalga_hizi) * dalga_miktari

	else:
		velocity.x = 0
		velocity.y = sin(zaman * dalga_hizi) * dalga_miktari
		
	move_and_slide()


func _on_visible_on_screen_notifier_2d_screen_entered():
	takip_basladi = true


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
	velocity = Vector2.ZERO 
	
	
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
	$AnimatedSprite2D.self_modulate = Color(10, 0, 0) 
	await get_tree().create_timer(0.1).timeout
	if not is_dead and has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.self_modulate = Color(1, 1, 1) 


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "die":
		queue_free()
