extends Button

signal cycle_parts_list()

var current = "Attached"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	emit_signal("cycle_parts_list")
	if current == "Attached":
		current = "Placeable"
	else:
		current = "Attached"
	text = "List mode:\n" + current
