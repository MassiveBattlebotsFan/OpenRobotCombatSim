extends Button

const BASE_TEXT = "Camera mode:\n"

signal update_camera_mode(orthogonal : bool)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _toggled(button_pressed):
	emit_signal("update_camera_mode", button_pressed)
	if button_pressed:
		text = BASE_TEXT + "Orthogonal"
	else:
		text = BASE_TEXT + "Perspective"
