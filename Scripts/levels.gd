extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
