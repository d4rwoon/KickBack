extends RichTextLabel

func _ready():
	add_to_group("labels")
	text = "[shake rate=10 level=5][outline_size=4][outline_color=black][color=#ff8c00]Death Count : " + str(Global.olum_sayisi) + "[/color][/outline_color][/outline_size][/shake]"

func update_death_text(yeni_deger):
	text = "[shake rate=10 level=5][outline_size=4][outline_color=black][color=#ff8c00]Death Count : " + str(yeni_deger) + "[/color][/outline_color][/outline_size][/shake]"
