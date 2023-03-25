extends Node3D

@onready var RobotConstruction = $RobotConstruction

signal update_camera_mode(orthogonal : bool)
signal part_list_update_items(add : bool, name : String, node_reference : Node3D)
signal part_selected(node_reference)
signal parts_dict_ready()
signal attachable_part_selected(mesh_ref)
signal attachable_part_deselected()
signal part_list_clear_all_attached()

@export var parts_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	init_or_load_userdata()
	"""var boxmesh = BoxMesh.new()
	boxmesh.size = Vector3(0.1,0.1,0.1)
	parts_dict["Cube"] = [boxmesh.get_mesh_arrays(), boxmesh.get_faces()]"""
	#print(parts_dict)
	emit_signal("parts_dict_ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_camera_mode_update_camera_mode(orthogonal):
	emit_signal("update_camera_mode", orthogonal)
	pass # Replace with function body.


func _on_robot_construction_part_list_update_items(add : bool, node_reference : Node):
	emit_signal("part_list_update_items", add, node_reference)


func _on_camera_position_controller_part_selected(node_reference):
	emit_signal("part_selected", node_reference)


func _on_part_lists_container_placeable_part_cleared():
	print("cleared placeable part")
	RobotConstruction.active_placeable_part["mesh"][0] = null
	RobotConstruction.active_placeable_part["mesh"][1] = null
	RobotConstruction.active_placeable_part["name"] = ""


func _on_part_lists_container_placeable_part_selected(part_name):
	if parts_dict.get(part_name, false):
		print("selected placeable part ", part_name)
		RobotConstruction.active_placeable_part["name"] = part_name
		RobotConstruction.active_placeable_part["mesh"][0] = parts_dict[part_name][0]
		RobotConstruction.active_placeable_part["mesh"][1] = parts_dict[part_name][1]
	else:
		printerr("Part \"", part_name, "\" not found!")


func _on_robot_construction_part_list_clear_all_attached():
	emit_signal("part_list_clear_all_attached")


func load_wavefront_obj(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var data
	var part_name = ""
	var vertices = []
	var normals = []
	var uvs = []
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	while not file.eof_reached():
		data = file.get_line()
		data = data.split(" ")
		if data[0] == "o":
			part_name = data[1]
		if data[0] == "v":
			vertices.push_back(Vector3(float(data[1]), float(data[2]), float(data[3])))
		if data[0] == "vt":
			uvs.push_back(Vector2(float(data[1]), float(data[2])))
		if data[0] == "vn":
			normals.push_back(Vector3(float(data[1]), float(data[2]), float(data[3])))
		if data[0] == "f":
			if len(data) != 4:
				printerr("Error: Not triangulated")
				return
			var facedata = data[3].split("/")
			if OS.is_debug_build():
				print(facedata)
			mesh.surface_set_normal(normals[int(facedata[2]) - 1])
			mesh.surface_set_uv(uvs[int(facedata[1]) - 1])
			#mesh.surface_set_uv2(-uvs[int(facedata[1]) - 1])
			mesh.surface_add_vertex(vertices[int(facedata[0]) - 1])
			facedata = data[2].split("/")
			if OS.is_debug_build():
				print(facedata)
			mesh.surface_set_normal(normals[int(facedata[2]) - 1])
			mesh.surface_set_uv(uvs[int(facedata[1]) - 1])
			#mesh.surface_set_uv2(-uvs[int(facedata[1]) - 1])
			mesh.surface_add_vertex(vertices[int(facedata[0]) - 1])
			facedata = data[1].split("/")
			if OS.is_debug_build():
				print(facedata)
			mesh.surface_set_normal(normals[int(facedata[2]) - 1])
			mesh.surface_set_uv(uvs[int(facedata[1]) - 1])
			#mesh.surface_set_uv2(-uvs[int(facedata[1]) - 1])
			mesh.surface_add_vertex(vertices[int(facedata[0]) - 1])
	file.close()
	mesh.surface_end()
	parts_dict[part_name] = [mesh, mesh.get_faces()]


func init_or_load_userdata():
	var user_dir = DirAccess.open("user://")
	if not user_dir:
		printerr("Error: Could not open user data. Quitting...")
		get_tree().quit()
	if not user_dir.dir_exists("parts/"):
		user_dir.make_dir("parts/")
	if not user_dir.dir_exists("bots/"):
		user_dir.make_dir("bots/")
	user_dir.change_dir("parts/")
	user_dir.list_dir_begin()
	var file_name = user_dir.get_next()
	while file_name != "":
		if file_name.get_extension() == "obj":
			print("user://parts/" + file_name)
			load_wavefront_obj("user://parts/" + file_name)
		file_name = user_dir.get_next()
	#var boxmesh = BoxMesh.new()
	#boxmesh.size = Vector3(0.1,0.1,0.1)
	#parts_dict["Cube"] = [boxmesh.get_mesh_arrays(), boxmesh.get_faces()]


func _on_save_file_dialog_file_selected(path):
	print("saving to: ", path)
	var save_file = FileAccess.open(path, FileAccess.WRITE_READ)
	var save_data = RobotConstruction.dump_construction_csv()
	print(save_data)
	save_file.store_string(save_data)
	save_file.close()


func _on_load_file_dialog_file_selected(path):
	print("loading from: ", path)
	var load_file = FileAccess.open(path, FileAccess.READ)
	if not load_file:
		printerr("Could not open ", path)
		load_file.close()
		return
	var load_data = load_file.get_as_text(true).split("\n")
	print(load_data)
	RobotConstruction.reconstruct_from_csv(load_data)
