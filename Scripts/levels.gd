extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Görseldeki buton sıranı birebir aynı şekilde listeledim
	var butonlar = [
		$VBoxContainer/Button,   # 1. Level Butonu
		$VBoxContainer/Button2,  # 2. Level Butonu
		$VBoxContainer/Button3,  # 3. Level Butonu
		$VBoxContainer/Button5,  # 4. Level Butonu
		$VBoxContainer/Button6   # 5. Level Butonu
	]
	
	for i in range(butonlar.size()):
		var level_no = i + 1
		var btn = butonlar[i]
		
		# Eğer butonun temsil ettiği level, açtığımız maksimum levelden büyükse onu KİLİTLE
		if level_no > Global.acilan_maksimum_level:
			btn.disabled = true
			btn.text = str(level_no) + " [ 🔒 ]"
		else:
			# Eğer açıksa tıklanabilir yap ve sadece numarasını yaz
			btn.disabled = false
			btn.text = str(level_no)


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
