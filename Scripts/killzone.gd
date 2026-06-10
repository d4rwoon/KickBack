extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		if body.has_method("ol"):
			# YENİ: Parantez içine 'true' yazarak "animasyonu es geç, anında yenile" diyoruz!
			body.ol(true)
