extends RichTextLabel

# --- YENİ: Artık her bölümün hedefini Inspector'dan elle belirleyebileceksin ---
@export var bolum_hedefi: int = 3

var portal_dugumu = null

func _process(_delta):
	# Portal sahnede yoksa bulmaya çalış
	if not is_instance_valid(portal_dugumu):
		portal_dugumu = get_tree().get_first_node_in_group("portal")
	
	# Başlangıçta Inspector'dan girdiğin değeri baz al
	var gereken = bolum_hedefi
	
	# Eğer portal sahnede doğduysa ve bulunduysa, onun kendi içindeki değeri oku
	if is_instance_valid(portal_dugumu):
		gereken = portal_dugumu.gereken_jeton
		
	# Ekrana yazdır
	text = "[rainbow freq=0.2 sat=0.6 val=0.9][wave amp=25 freq=3]COINS:[/wave][/rainbow] [wave amp=20 freq=4]( " + str(Global.jeton_sayisi) + "/" + str(gereken) + " )[/wave]"
