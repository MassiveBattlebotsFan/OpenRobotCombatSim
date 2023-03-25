extends Button

@onready var file_diag = $SaveFileDialog

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	file_diag.popup_centered(Vector2i(400,320))
