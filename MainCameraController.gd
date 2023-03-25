extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_robot_editor_base_update_camera_mode(orthogonal : bool):
	if orthogonal:
		projection = Camera3D.PROJECTION_ORTHOGONAL
		size = 3
	else:
		projection = Camera3D.PROJECTION_PERSPECTIVE
		fov = 75
