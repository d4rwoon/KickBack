extends CanvasLayer

@onready var anim = $AnimationPlayer

func sahne_degistir(hedef_yol: String):
	
	if anim:
		anim.play("fade_to_black")
		await anim.animation_finished
	
	get_tree().change_scene_to_file(hedef_yol)
	
	if anim:
		anim.play("fade_from_black")
