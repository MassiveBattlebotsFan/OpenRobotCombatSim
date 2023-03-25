extends ItemList


@onready var RobotEditorBase = $"/root/UIController/SubViewportContainer/SubViewport/RobotEditorBase"
var is_parts_dict_ready : bool = false

func _ready():
	if is_parts_dict_ready:
		is_parts_dict_ready = false
		for key in RobotEditorBase.parts_dict:
			add_item(key)
	else:
		printerr("Attachable parts dict not ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_robot_editor_base_parts_dict_ready():
	is_parts_dict_ready = true
