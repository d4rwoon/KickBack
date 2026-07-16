extends RichTextLabel

@export var bolum_hedefi: int = 3

var portal_dugumu = null

func _process(_delta):
	if not is_instance_valid(portal_dugumu):
		portal_dugumu = get_tree().get_first_node_in_group("portal")
	
	var gereken = bolum_hedefi
	
	if is_instance_valid(portal_dugumu):
		gereken = portal_dugumu.gereken_jeton
		
	text = "[rainbow freq=0.2 sat=0.6 val=0.9][wave amp=25 freq=3]COINS:[/wave][/rainbow] [wave amp=20 freq=4]( " + str(Global.jeton_sayisi) + "/" + str(gereken) + " )[/wave]"
