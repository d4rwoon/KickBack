extends HSlider

@export var bus_name: String = "Music"

@export var volume_label: Label 

var bus_index: int

func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
	
	update_label_text(value)
	
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float):
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
	
	update_label_text(new_value)


func update_label_text(current_value: float):
	if volume_label:
		
		var percentage = int(current_value * 100)
		volume_label.text = "Music: %" + str(percentage)
