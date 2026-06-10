extends HSlider

@export var bus_name: String = "Music"
# Inspector'dan atamak üzere Label referansı oluşturuyoruz
@export var volume_label: Label 

var bus_index: int

func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
	# Oyun başladığında metni ilk değere göre ayarla
	update_label_text(value)
	
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float):
	# Sesi güncelle
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
	# Metni güncelle
	update_label_text(new_value)

# Metni güncelleyen özel fonksiyonumuz
func update_label_text(current_value: float):
	if volume_label:
		# 0.0 - 1.0 arasındaki değeri 100 ile çarpıp tam sayıya (int) çeviriyoruz
		var percentage = int(current_value * 100)
		volume_label.text = "Music: %" + str(percentage)
