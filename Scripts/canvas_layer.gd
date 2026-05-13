extends Line2D

var queue : Array
@export var MAX_LENGHT : int

func _process(_delta):
	var pos = get_global_mouse_position()
	queue.push_front(pos)
	
	if queue.size() > MAX_LENGHT:
		queue.pop_back()
	
	clear_points()
	
	for point in queue:
		add_point(point)
