extends Control

@onready var part_list = $PartListsContainer/AttachedPartList

@onready var pos_X_field = $MoveWidgetContainer/Position/X
@onready var pos_Y_field = $MoveWidgetContainer/Position/Y
@onready var pos_Z_field = $MoveWidgetContainer/Position/Z

@onready var rot_X_field = $MoveWidgetContainer/Rotation/X
@onready var rot_Y_field = $MoveWidgetContainer/Rotation/Y
@onready var rot_Z_field = $MoveWidgetContainer/Rotation/Z

@onready var scl_X_field = $MoveWidgetContainer/Scale/X
@onready var scl_Y_field = $MoveWidgetContainer/Scale/Y
@onready var scl_Z_field = $MoveWidgetContainer/Scale/Z

@onready var highlighted_tex = preload("res://HighlightedPartTex.tres")
@onready var Origin = $SubViewportContainer/SubViewport/RobotEditorBase/RobotConstruction/Origin
@onready var RobotConstruction = $SubViewportContainer/SubViewport/RobotEditorBase/RobotConstruction
@onready var PartListsContainer = $PartListsContainer

var selected_node

#signal delete_selected_part(target)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventKey and event.is_action_pressed("ui_graph_delete") and selected_node != null and PartListsContainer.active_part_list == CustomDatatypes.PartLists.PLACEABLE_PARTS:
		print("delete_part")
		#emit_signal("delete_selected_part", selected_node)
		if selected_node == Origin:
			print("Cannot delete Origin!")
			return
		if selected_node.prepare_delete():
			selected_node.free()
			RobotConstruction.update_children()
		else:
			printerr("hover_target failed to prepare for delete, aborting")

func init_selected_item(index):
	print("idx: ", index)
	selected_node = part_list.part_list[index]
	pos_X_field.set_value_no_signal(selected_node.global_position.x)
	pos_X_field.get_line_edit().text = str(selected_node.global_position.x)
	pos_Y_field.set_value_no_signal(selected_node.global_position.y)
	pos_Y_field.get_line_edit().text = str(selected_node.global_position.y)
	pos_Z_field.set_value_no_signal(selected_node.global_position.z)
	pos_Z_field.get_line_edit().text = str(selected_node.global_position.z)
	pos_X_field.editable = true
	pos_Y_field.editable = true
	pos_Z_field.editable = true
	
	rot_X_field.set_value_no_signal(rad_to_deg(selected_node.global_rotation.x))
	rot_X_field.get_line_edit().text = str(round(rad_to_deg(selected_node.global_rotation.x)*CustomDatatypes.VALUE_ROUND)/CustomDatatypes.VALUE_ROUND)
	rot_Y_field.set_value_no_signal(rad_to_deg(selected_node.global_rotation.y))
	rot_Y_field.get_line_edit().text = str(round(rad_to_deg(selected_node.global_rotation.y)*CustomDatatypes.VALUE_ROUND)/CustomDatatypes.VALUE_ROUND)
	rot_Z_field.set_value_no_signal(rad_to_deg(selected_node.global_rotation.z))
	rot_Z_field.get_line_edit().text = str(round(rad_to_deg(selected_node.global_rotation.z)*CustomDatatypes.VALUE_ROUND)/CustomDatatypes.VALUE_ROUND)
	rot_X_field.editable = true
	rot_Y_field.editable = true
	rot_Z_field.editable = true
	
	scl_X_field.set_value_no_signal(selected_node.current_scale.x)
	scl_X_field.get_line_edit().text = str(round(selected_node.current_scale.x*CustomDatatypes.VALUE_ROUND)/CustomDatatypes.VALUE_ROUND)
	scl_Y_field.set_value_no_signal(selected_node.current_scale.y)
	scl_Y_field.get_line_edit().text = str(round(selected_node.current_scale.y*CustomDatatypes.VALUE_ROUND)/CustomDatatypes.VALUE_ROUND)
	scl_Z_field.set_value_no_signal(selected_node.current_scale.z)
	scl_Z_field.get_line_edit().text = str(round(selected_node.current_scale.z*CustomDatatypes.VALUE_ROUND)/CustomDatatypes.VALUE_ROUND)
	scl_X_field.editable = selected_node.properties["scalable"]
	scl_Y_field.editable = selected_node.properties["scalable"]
	scl_Z_field.editable = selected_node.properties["scalable"]

func _on_attached_part_list_item_selected(index):
	_on_robot_editor_base_part_selected(part_list.part_list[index])

func _on_part_list_mode_cycle_parts_list():
	if selected_node != null:
		selected_node.VisualMesh.set_surface_override_material(0, null)
	selected_node = null
	pos_X_field.set_value_no_signal(0)
	pos_Y_field.set_value_no_signal(0)
	pos_Z_field.set_value_no_signal(0)
	pos_X_field.editable = false
	pos_Y_field.editable = false
	pos_Z_field.editable = false
	
	rot_X_field.set_value_no_signal(0)
	rot_Y_field.set_value_no_signal(0)
	rot_Z_field.set_value_no_signal(0)
	rot_X_field.editable = false
	rot_Y_field.editable = false
	rot_Z_field.editable = false
	
	scl_X_field.set_value_no_signal(1)
	scl_Y_field.set_value_no_signal(1)
	scl_Z_field.set_value_no_signal(1)
	scl_X_field.editable = false
	scl_Y_field.editable = false
	scl_Z_field.editable = false

func _on_pos_x_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	var updated_pos = selected_node.global_position
	updated_pos.x = value
	selected_node.update_position(updated_pos)


func _on_pos_y_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	var updated_pos = selected_node.global_position
	updated_pos.y = value
	selected_node.update_position(updated_pos)


func _on_pos_z_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	var updated_pos = selected_node.global_position
	updated_pos.z = value
	selected_node.update_position(updated_pos)


func _on_rot_x_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	var updated_rot = selected_node.global_rotation
	updated_rot.x = deg_to_rad(value)
	selected_node.update_rotation(updated_rot)


func _on_rot_y_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	var updated_rot = selected_node.global_rotation
	updated_rot.y = deg_to_rad(value)
	selected_node.update_rotation(updated_rot)


func _on_rot_z_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	var updated_rot = selected_node.global_rotation
	updated_rot.z = deg_to_rad(value)
	selected_node.update_rotation(updated_rot)


func _on_scl_x_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	if selected_node.properties["scalable"] == false:
		print("Warn: ", selected_node, " not scalable")
		return
	var updated_scl = selected_node.scale
	updated_scl.x = value
	selected_node.update_scale(updated_scl)


func _on_scl_y_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	if selected_node.properties["scalable"] == false:
		print("Warn: ", selected_node, " not scalable")
		return
	var updated_scl = selected_node.scale
	updated_scl.y = value
	selected_node.update_scale(updated_scl)


func _on_scl_z_value_changed(value):
	if selected_node == null:
		print("Warn: selected_node null")
		return
	if selected_node.properties["scalable"] == false:
		print("Warn: ", selected_node, " not scalable")
		return
	var updated_scl = selected_node.scale
	updated_scl.z = value
	selected_node.update_scale(updated_scl)

func _on_robot_editor_base_part_selected(node_reference):
	if selected_node != null:
		selected_node.VisualMesh.set_surface_override_material(0, null)
	selected_node = node_reference
	selected_node.VisualMesh.set_surface_override_material(0, highlighted_tex)
	var idx = part_list.part_list.find(node_reference)
	part_list.select(idx)
	init_selected_item(idx)

