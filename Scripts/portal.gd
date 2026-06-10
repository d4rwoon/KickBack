extends Area2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var yetersiz_yazisi = $YetersizYazisi
@onready var portal_sesi = $PortalSesi
@onready var yetersiz_sesi = $YetersizSesi

@export_file("*.tscn") var hedef_sahne : String = "res://Scenes/main_menu.tscn"
@export var gereken_jeton : int = 3
@export var bu_levelin_numarasi : int = 1

func _ready():
	add_to_group("portal")
	
	if anim_sprite:
		anim_sprite.play("portalanimation")
		
	if yetersiz_yazisi:
		yetersiz_yazisi.modulate.a = 0.0
	
	body_entered.connect(_on_portal_body_entered)

func _on_portal_body_entered(body):
	if body.name == "Player":
		if Global.jeton_sayisi >= gereken_jeton:
			if portal_sesi:
				portal_sesi.play()
				
			body.set_physics_process(false)
			if "velocity" in body:
				body.velocity = Vector2.ZERO
			
			Global.jeton_sayisi = 0
			
			if Global.acilan_maksimum_level <= bu_levelin_numarasi:
				Global.acilan_maksimum_level = bu_levelin_numarasi + 1
				
			sahne_degistir()
		else:
			if yetersiz_sesi:
				yetersiz_sesi.play()
				
			if yetersiz_yazisi:
				yetersiz_yazisi.text = "[center][color=red][wave amp=20 freq=4]Not Enough Coins![/wave][/color][/center]"
				var tween = create_tween()
				tween.tween_property(yetersiz_yazisi, "modulate:a", 1.0, 0.3)
				tween.tween_interval(1.5)
				tween.tween_property(yetersiz_yazisi, "modulate:a", 0.0, 0.5)

func sahne_degistir():
	if hedef_sahne == "":
		return
	TransitionLayer.sahne_degistir(hedef_sahne)
