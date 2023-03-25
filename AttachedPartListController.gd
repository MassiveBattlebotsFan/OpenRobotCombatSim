extends ItemList

@export var part_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_robot_editor_base_part_list_update_items(add : bool, node_reference : Node):
	if add:
		part_list.push_back(node_reference)
		add_item(node_reference.name, null, true)
	else:
		var r_idx = part_list.rfind(node_reference)
		deselect(r_idx+1)
		remove_item(r_idx+1)
		part_list.remove_at(r_idx)


func _on_robot_editor_base_part_list_clear_all_attached():
	part_list.clear()
	clear()
