extends Area2D


@onready var animasyon_dugumu = $AnimatedSprite2D 

func _ready():
	animasyon_dugumu.play("spike")

func _on_body_entered(body):
	if body.name == "Player":
		body.set_physics_process(false)
		var mevcut_bolum = get_tree().current_scene.scene_file_path
		TransitionLayer.sahne_degistir(mevcut_bolum)
