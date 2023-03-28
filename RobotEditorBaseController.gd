extends Node3D

const USERDATA_DIRS = ["parts/", "bots/", "parts/ESCs/models/", "parts/motors/models/", "parts/motors/configs/", "parts/ESCs/configs/"]

@onready var RobotConstruction = $RobotConstruction

signal update_camera_mode(orthogonal : bool)
signal part_list_update_items(add : bool, name : String, node_reference : Node3D)
signal part_selected(node_reference)
signal parts_dict_ready()
signal attachable_part_selected(mesh_ref)
signal attachable_part_deselected()
signal part_list_clear_all_attached()

@export var parts_dict = {}
@export var constructed_motors = {}

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
	## Loads a Wavefront OBJ from specified path
	## Returns Array of [part_name, mesh], or null on error
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		file.close()
		return null
	var data
	var part_name = ""
	var vertices = []
	var normals = []
	var uvs = []
	var faces = []
	while not file.eof_reached():
		data = file.get_line()
		data = data.split(" ")
		if data[0] == "o":
			part_name = data[1]
			faces.push_back({"name" : part_name, "face_ids" : []})
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
			faces.back()["face_ids"].push_back(Vector3i(int(facedata[0]) - 1, int(facedata[1]) - 1, int(facedata[2]) - 1))
			facedata = data[2].split("/")
			faces.back()["face_ids"].push_back(Vector3i(int(facedata[0]) - 1, int(facedata[1]) - 1, int(facedata[2]) - 1))
			facedata = data[1].split("/")
			faces.back()["face_ids"].push_back(Vector3i(int(facedata[0]) - 1, int(facedata[1]) - 1, int(facedata[2]) - 1))
	file.close()
	var data_to_return = []
	for face in faces:
		var mesh = [face["name"], ImmediateMesh.new()]
		mesh[1].surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		for id in face["face_ids"]:
			mesh[1].surface_set_normal(normals[id.z])
			mesh[1].surface_set_uv(uvs[id.y])
			mesh[1].surface_add_vertex(vertices[id.x])
		mesh[1].surface_end()
		data_to_return.push_back(mesh)
	return data_to_return

func load_cmplx_part_config(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		file.close()
		return null
	var data
	var config_file = {}
	data = file.get_as_text(true).split("\n")
	file.close()
	for line in data:
		var split_line = line.split(" : ")
		config_file[split_line[0]] = split_line[1]
	return config_file

func init_or_load_userdata():
	var user_dir = DirAccess.open("user://")
	if not user_dir:
		printerr("Error: Could not open user data. Quitting...")
		get_tree().quit()
	for dir in USERDATA_DIRS:
		if not user_dir.dir_exists(dir):
			var error = user_dir.make_dir_recursive(dir)
			if error != OK:
				print("Error in init_or_load_userdata: ", error_string(error))
				get_tree().quit(1)
	user_dir.change_dir("parts/")
	user_dir.list_dir_begin()
	var file_name = user_dir.get_next()
	while file_name != "":
		if not user_dir.current_is_dir() and file_name.get_extension() == "obj":
			print("user://parts/" + file_name)
			var returned_parts = load_wavefront_obj("user://parts/" + file_name)
			if returned_parts == null:
				printerr("Error: File not openable, exiting...")
				get_tree().quit(2)
			for returned_part in returned_parts:
				parts_dict[returned_part[0]] = [returned_part[1], returned_part[1].get_faces(), false]
		file_name = user_dir.get_next()
	user_dir.list_dir_end()
	user_dir.change_dir("motors/models/")
	user_dir.list_dir_begin()
	file_name = user_dir.get_next()
	while file_name != "":
		if file_name.get_extension() == "obj":
			print("user://parts/motors/models/" + file_name)
			var returned_parts = load_wavefront_obj("user://parts/motors/models/" + file_name)
			if returned_parts == null:
				printerr("Error: File not openable, exiting...")
				get_tree().quit(2)
			constructed_motors[file_name.get_slice(".", 0)] = {"config" : {}, "meshes" : returned_parts}
		file_name = user_dir.get_next()
	user_dir.list_dir_end()
	user_dir.change_dir("../configs/")
	user_dir.list_dir_begin()
	file_name = user_dir.get_next()
	while file_name != "":
		if file_name.get_extension() == "ini":
			print("user://parts/motors/configs/" + file_name)
			var config_dat = load_cmplx_part_config("user://parts/motors/configs/" + file_name)
			if config_dat == null:
				printerr("Error: File not openable, exiting...")
				get_tree().quit(2)
			var c_idx = file_name.get_slice(".", 0)
			constructed_motors[c_idx]["config"] = config_dat
			var mesh_to_add_to_parts_dict = constructed_motors[c_idx]["meshes"].filter(func(arr): return arr[0] == config_dat["base"])[0][1]
			parts_dict[c_idx] = [mesh_to_add_to_parts_dict, mesh_to_add_to_parts_dict.get_faces(), true]
		file_name = user_dir.get_next()
	if OS.is_debug_build():
		print(constructed_motors)

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

func _on_run_button_pressed():
	print(RobotConstruction.get_children())
	for origin in RobotConstruction.get_children():
		origin.freeze = false
