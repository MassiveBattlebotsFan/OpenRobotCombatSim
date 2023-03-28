extends Node3D

signal part_list_update_items(add : bool, node_reference : Node)
signal part_list_clear_all_attached()

@export var active_placeable_part = {"name" : "", "mesh" : [null, null]}
@onready var Origin = $Origin
@onready var part_script = preload("res://RobotPartController.gd")
@onready var part_generic_material = preload("res://GenericPartTex.tres")

# Called when the node enters the scene tree for the first time.

func update_children():
	emit_signal("part_list_clear_all_attached")
	var children = get_children()
	for child in children:
		emit_signal("part_list_update_items", true, child)

func _ready():
	update_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func construct_part(mesh, mesh_name, part_title):
	var new_part = StaticBody3D.new()
	var new_coll3d = CollisionShape3D.new()
	var new_coll_mesh = ConcavePolygonShape3D.new()
	var new_meshinstance3d = MeshInstance3D.new()
	new_part.name = part_title
	new_coll_mesh.set_faces(mesh[1])
	new_coll3d.shape = new_coll_mesh
	new_coll3d.name = "Collider"
	#new_coll3d.owner = new_part
	new_meshinstance3d.mesh = mesh[0]
	new_meshinstance3d.mesh.surface_set_material(0, part_generic_material)
	new_meshinstance3d.name = "VisMesh3D"
	#new_meshinstance3d.owner = new_part
	new_part.add_child(new_meshinstance3d)
	new_part.add_child(new_coll3d)
	new_part.set_script(part_script)
	new_part.part_name = mesh_name
	new_part.properties["scalable"] = true
	return new_part

func _on_camera_position_controller_part_placed(hover_target):
	if OS.is_debug_build():
		print(active_placeable_part)
	var new_part = construct_part(active_placeable_part["mesh"], active_placeable_part["name"], active_placeable_part["name"] + String.num_int64(get_child_count()))
	new_part.parents.push_back(hover_target)
	hover_target.children.push_back(new_part)
	add_child(new_part)
	update_children()

func dump_construction_raw():
	var dumped_data = {}
	var children = get_children()
	for child in children:
		dumped_data[child.name] = [child.part_name, child.parents, child.children, child.global_position, child.global_rotation_degrees, child.current_scale]
	return dumped_data

func dump_construction_csv():
	var csv_data = "" # part, pos, rot, scl, parents, children
	var raw_dumped_data = dump_construction_raw()
	for child_name in raw_dumped_data:
		var child = raw_dumped_data[child_name]
		csv_data += child_name + "," + child[0] + ","
		csv_data += str(child[3].x) + "," + str(child[3].y) + "," + str(child[3].z) + ","
		csv_data += str(round(child[4].x*CustomDatatypes.VALUE_ROUND)) + "," + str(round(child[4].y*CustomDatatypes.VALUE_ROUND)) + "," + str(round(child[4].z*CustomDatatypes.VALUE_ROUND)) + ","
		csv_data += str(round(child[5].x*CustomDatatypes.VALUE_ROUND)) + "," + str(round(child[5].y*CustomDatatypes.VALUE_ROUND)) + "," + str(round(child[5].z*CustomDatatypes.VALUE_ROUND)) + ","
		csv_data += "parents,"
		for parent in child[1]:
			csv_data += parent.name + ","
		csv_data += "children"
		for child_children in child[2]:
			csv_data += "," + child_children.name
		csv_data += "\n"
	return csv_data

func initialize_parts_from_csv(data):
	var initialized_parts = []
	var parts_dict = get_parent().parts_dict
	for line in data:
		if OS.is_debug_build():
			print(line)
		if line == "":
			continue
		var split_line = line.split(",")
		var pos = Vector3(float(split_line[2]),float(split_line[3]),float(split_line[4]))
		var rot = Vector3(deg_to_rad(float(split_line[5])/CustomDatatypes.VALUE_ROUND),deg_to_rad(float(split_line[6])/CustomDatatypes.VALUE_ROUND),deg_to_rad(float(split_line[7])/CustomDatatypes.VALUE_ROUND))
		var scl = Vector3(float(split_line[8])/CustomDatatypes.VALUE_ROUND,float(split_line[9])/CustomDatatypes.VALUE_ROUND,float(split_line[10])/CustomDatatypes.VALUE_ROUND)
		var parents = []
		var children = []
		var push_to_children = false
		for i in split_line.slice(12):
			if OS.is_debug_build():
				print(i)
			if i == "children":
				push_to_children = true
				continue
			if push_to_children:
				children.push_back(i)
			else:
				parents.push_back(i)
		if split_line[1] == "None":
			initialized_parts.push_back({"part" : Origin, "children" : children, "parents" : parents, "pos" : pos, "rot" : rot, "scl" : scl})
			continue
		if parts_dict[split_line[1]] == null:
			printerr("Part ", split_line[1], " not found!")
		initialized_parts.push_back({"part" : construct_part(parts_dict[split_line[1]], split_line[1], split_line[0]), "children" : children, "parents" : parents, "pos" : pos, "rot" : rot, "scl" : scl})
	if OS.is_debug_build():
		print(initialized_parts)
	return initialized_parts

func reconstruct_from_csv(data):
	## Reconstructs CSV data into parts
	var current_origin = Origin
	current_origin.propagate_part_deletion()
	#for child in get_children():
	#	if child != current_origin:
	#		child.free()
	update_children()
	var initialized_parts = initialize_parts_from_csv(data)
	for part in initialized_parts:
		for parent in part["parents"]:
			print(parent)
			part["part"].parents.push_back(initialized_parts.filter(func(dict): return dict["part"].name == parent)[0]["part"])
		for child in part["children"]:
			print(child)
			part["part"].children.push_back(initialized_parts.filter(func(dict): return dict["part"].name == child)[0]["part"])
		if part["part"] != Origin:
			add_child(part["part"])
		#part["part"].hide()
	for part in initialized_parts:
		part["part"].update_position(part["pos"])
		part["part"].update_rotation(part["rot"], false)
		part["part"].update_scale(part["scl"])
		#part["part"].show()
	update_children()
