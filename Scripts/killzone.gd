extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("ol"):
			
			body.ol(true)
