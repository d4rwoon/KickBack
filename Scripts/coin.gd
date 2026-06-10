extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var toplama_sesi = $CoinToplamaSesi

func _ready():
	sprite.play("coin") 

func _on_body_entered(body):
	if body.name == "Player":
		toplama_islemi()

func toplama_islemi():
	Global.jeton_sayisi += 1
	get_tree().call_group("labels", "update_coin_text", Global.jeton_sayisi)
	
	collision.set_deferred("disabled", true)
	
	if toplama_sesi:
		toplama_sesi.play()
		
	if sprite.sprite_frames.has_animation("collected"):
		sprite.play("collected")
		await sprite.animation_finished
		
	sprite.visible = false
		
	if toplama_sesi and toplama_sesi.playing:
		await toplama_sesi.finished
		
	queue_free()
