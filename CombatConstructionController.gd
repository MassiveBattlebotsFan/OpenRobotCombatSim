extends Node3D

signal part_list_update_items(add : bool, node_reference : Node)
signal part_list_clear_all_attached()

@export var origins_just_parts = []
@export var active_placeable_part = {"name" : "", "mesh" : [null, null]}
@onready var Origin = $Origin
@onready var part_script = preload("res://RobotPartController.gd")
@onready var hinge_script = preload("res://RobotHingeController.gd")
@onready var static_control_script = preload("res://StaticControlSystem.gd")
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
	#for origin in get_children():
	#	print("\n", origin, ", ", origin.global_position)

func construct_rigidbody_axle(part, part_name, parent_name, thing_to_attach_to):
	var new_hinge = HingeJoint3D.new()
	var new_rigidbody = RigidBody3D.new()
	var new_mesh = MeshInstance3D.new()
	#var new_coll_mesh = ConcavePolygonShape3D.new()
	new_rigidbody.name = part_name
	new_mesh.name = "VisMesh3D"
	new_mesh.mesh = part
	new_mesh.mesh.surface_set_material(0, part_generic_material)
	new_rigidbody.add_child(new_mesh)
	new_rigidbody.set_script(part_script)
	new_rigidbody.part_name = part_name
	new_rigidbody.can_sleep = false
	new_rigidbody.properties["is_combat"] = true
	new_hinge.set_script(hinge_script)
	new_hinge.RigidBody = new_rigidbody
	add_child(new_hinge)
	return new_hinge

func construct_part(mesh, mesh_name, part_title):
	var new_part = CollisionShape3D.new()
	var new_coll_mesh = ConcavePolygonShape3D.new()
	var new_meshinstance3d = MeshInstance3D.new()
	new_coll_mesh.set_faces(mesh[1])
	new_part.shape = new_coll_mesh
	new_part.name = part_title
	#new_coll3d.owner = new_part
	new_meshinstance3d.mesh = mesh[0]
	new_meshinstance3d.mesh.surface_set_material(0, part_generic_material)
	new_meshinstance3d.name = "VisMesh3D"
	#new_meshinstance3d.owner = new_part
	new_part.add_child(new_meshinstance3d)
	if mesh[2]: #if part is a motor
		var axle_name = get_parent().constructed_motors[mesh_name]["config"]["axle"]
		var axle = get_parent().constructed_motors[mesh_name]["meshes"].filter(func(arr): return arr[0] == axle_name)[0][1]
		new_part.set_script(static_control_script)
		new_part.properties["scalable"] = false
		new_part.properties["is_motor"] = true
		new_part.properties["axle"] = construct_rigidbody_axle(axle, axle_name, part_title, new_part)
		new_part.add_child(new_part.properties["axle"].RigidBody)
		print("new_part.properties[\"axle\"]: ", new_part.properties["axle"])
		new_part.properties["axle"].RigidBody.parents.push_back(new_part)
		new_part.children.push_back(new_part.properties["axle"].RigidBody)
		Origin.children_to_control.push_back(new_part) # subject to change when StaticController is rebuilt
		new_part.control_type = CustomDatatypes.ControlTypes.TYPE_MOTOR
	else:
		new_part.set_script(part_script)
		new_part.properties["scalable"] = true
	new_part.part_name = mesh_name
	new_part.properties["is_combat"] = true
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
		var pos = Vector3(float(split_line[2]),float(split_line[3]),float(split_line[4])) + global_position
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
	var origins = []
	origins_just_parts = []
	var current_origin = Origin
	Origin.RigidBody = Origin
	Origin.control_type = CustomDatatypes.ControlTypes.TYPE_CONTROLLER
	current_origin.propagate_part_deletion()
	update_children()
	var initialized_parts = initialize_parts_from_csv(data)
	for part in initialized_parts:
		for parent in part["parents"]:
			print(parent)
			part["part"].parents.push_back(initialized_parts.filter(func(dict): return dict["part"].name == parent)[0]["part"])
		for child in part["children"]:
			print(child)
			if part["part"].properties["is_motor"]:
				part["part"].properties["axle"].RigidBody.children.push_back(initialized_parts.filter(func(dict): return dict["part"].name == child)[0]["part"])
			else:
				part["part"].children.push_back(initialized_parts.filter(func(dict): return dict["part"].name == child)[0]["part"])
		if part["part"].properties["is_motor"] or part["part"] == Origin:
			origins.push_back(part)
			origins_just_parts.push_back(part["part"])
			part["part"]
		#part["part"].hide()
		#part["part"].show()
	Origin.properties["axle"] = Origin
	Origin.assign_groups_recursive(0, origins_just_parts)
	for part in initialized_parts:
		#if not part["part"] in origins_just_parts:
		if part["part"] != origins_just_parts[part["part"].properties["group"]].properties["axle"].RigidBody:
			print("attached ", part["part"], " to ", origins_just_parts[part["part"].properties["group"]].properties["axle"].RigidBody)
			origins_just_parts[part["part"].properties["group"]].properties["axle"].RigidBody.add_child(part["part"])
		part["part"].update_position(part["pos"], false)
		part["part"].update_rotation(part["rot"], false)
		part["part"].update_scale(part["scl"])
	for origin in origins:
		origin["part"].properties["axle"].RigidBody.continuous_cd = true
		if origin["part"] == Origin:
			continue
		#add_child(origin["part"].properties["axle"])
		print("origin_axle_properties: ", origin["part"].properties["axle"].get_path())
		print("origin_parent: ", origin["part"].get_distant_parent().get_path())
		origin["part"].properties["axle"].RigidBody.freeze = true
		#print(Vector3(0,0,0.2).rotated(Vector3(1,0,0), origin["rot"].x).rotated(Vector3(0,1,0), origin["rot"].y).rotated(Vector3(0,0,1), origin["rot"].z))
		print(origin["part"].properties["axle"].global_position)
		origin["part"].properties["axle"].global_position = origin["pos"]
		origin["part"].properties["axle"].RigidBody.VisualMesh.global_position = origin["pos"]
		origin["part"].properties["axle"].global_rotation = origin["rot"]
		origin["part"].properties["axle"].RigidBody.VisualMesh.global_rotation = origin["rot"]
		origin["part"].properties["axle"].node_a = origin["part"].get_distant_parent().get_path()
		origin["part"].properties["axle"].node_b = origin["part"].properties["axle"].RigidBody.get_path()
		origin["part"].properties["axle"].set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, 0)
		#new_hinge.set_param(HingeJoint3D.PARAM_LIMIT_RELAXATION, 2)
		origin["part"].properties["axle"].exclude_nodes_from_collision = false
		origin["part"].properties["axle"].set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
	Origin.mass = 10.0
	update_children()
	for origin in origins_just_parts:
		print("\n", origin.properties["axle"], "\n")
		for child in origin.properties["axle"].RigidBody.get_children():
			print(child)
