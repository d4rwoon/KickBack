extends Control

@onready var main_buttons = $PanelContainer
@onready var options = $Options


func _ready():
	$AnimationPlayer.play("RESET")
	hide()


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	
	main_buttons.visible = true
	options.visible = false
	
	hide()

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	show()

func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()

func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _process(delta):
	testEsc()


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_back_pressed() -> void:
	options.visible = false
	main_buttons.visible = true
