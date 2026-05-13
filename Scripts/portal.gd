extends Area2D

@onready var anim_sprite = $AnimatedSprite2D
@export_file("*.tscn") var hedef_sahne : String = "res://Scenes/level_2.tscn"
@export var gereken_jeton : int = 3

func _ready():
	if anim_sprite:
		anim_sprite.play("portalanimation")
	
	body_entered.connect(_on_portal_body_entered)

func _on_portal_body_entered(body):
	
	if body.name == "Player":
		
		if Global.jeton_sayisi >= gereken_jeton:
			body.set_physics_process(false)
			if "velocity" in body:
				body.velocity = Vector2.ZERO
			
			sahne_degistir()
		else:
			print("Daha fazla jeton lazım! Gereken: ", gereken_jeton)

func sahne_degistir():
	if hedef_sahne == "":
		
		return
		
	
	TransitionLayer.sahne_degistir(hedef_sahne)
