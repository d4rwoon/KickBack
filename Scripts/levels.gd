extends Control



func _ready():
	
	var butonlar = [
		$VBoxContainer/Button,   
		$VBoxContainer/Button2,  
		$VBoxContainer/Button3, 
		$VBoxContainer/Button5,  
		$VBoxContainer/Button6   
	]
	
	for i in range(butonlar.size()):
		var level_no = i + 1
		var btn = butonlar[i]
		
		
		if level_no > Global.acilan_maksimum_level:
			btn.disabled = true
			btn.text = str(level_no) + " [ 🔒 ]"
		else:
			
			btn.disabled = false
			btn.text = str(level_no)



func _process(delta: float) -> void:
	pass


func _on_level1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")


func _on_level2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")


func _on_level3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_3.tscn")


func _on_backttomenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_level_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_4.tscn")


func _on_level_5_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_5.tscn")
