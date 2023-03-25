extends RigidBody3D

@export var VisualMesh : MeshInstance3D = null
@export var CollisionMesh : CollisionShape3D = null

@export_category("part_info")
@export var part_name = "None"
@export var parents = []
@export var properties = {"scalable" : false, "is_motor" : false}
@export var children = []
@export var local_position = Vector3.ZERO
@export var local_rotation = Vector3.ZERO


func update_local():
	global_rotation_degrees = round(global_rotation_degrees * CustomDatatypes.VALUE_ROUND) / CustomDatatypes.VALUE_ROUND
	scale = round(scale * CustomDatatypes.VALUE_ROUND) / CustomDatatypes.VALUE_ROUND
	if len(parents) > 0:
		local_rotation = global_rotation_degrees - parents[0].global_rotation_degrees
		local_position = global_position - parents[0].global_position
		local_position = local_position.rotated(Vector3(1,0,0), -parents[0].global_rotation.x)
		local_position = local_position.rotated(Vector3(0,1,0), -parents[0].global_rotation.y)
		local_position = local_position.rotated(Vector3(0,0,1), -parents[0].global_rotation.z)
	else:
		local_position = global_position
		local_rotation = global_rotation_degrees
	print(self, " local_pos: ", local_position, ", local_rot: ", local_rotation)

func update_local_recursive():
	update_local()
	for child in children:
		child.update_local_recursive()

func remove_node_from_children(node_reference):
	children.erase(node_reference)

func prepare_delete():
	if len(children) == 0:
		for parent in parents:
			parent.remove_node_from_children(self)
		return true
	else:
		return false

func update_position(updated_pos : Vector3):
	update_position_recursive(updated_pos)
	update_local_recursive()

func update_position_recursive(updated_pos : Vector3):
	var diff = updated_pos - global_position
	global_position = updated_pos
	for child in children:
		child.update_position_recursive(child.global_position + diff)

func update_rotation(updated_rot : Vector3, recursive : bool = true):
	var old_rot = global_rotation
	global_rotation = Vector3.ZERO
	if recursive:
		update_rotation_recursive(updated_rot, global_position, old_rot)
	var old_scl = scale
	global_rotation = updated_rot
	scale_object_local(old_scl)
	update_local_recursive()

func update_rotation_recursive(updated_rot : Vector3, origin : Vector3, origin_rot : Vector3):
	if OS.is_debug_build():
		print("updated_rot: ", updated_rot)
		print("origin: ", origin)
		print("origin_rot: ", origin_rot)
	for child in children:
		var diff_rot = updated_rot - origin_rot
		#child.global_rotation = Vector3.ZERO
		var diff_pos = child.global_position - origin
		child.global_position = origin
		var old_scl = child.scale
		child.update_rotation_recursive(updated_rot, origin, origin_rot)
		child.global_rotation = diff_rot + child.global_rotation
		diff_pos = diff_pos.rotated(Vector3(1,0,0), diff_rot.x)
		diff_pos = diff_pos.rotated(Vector3(0,1,0), diff_rot.y)
		diff_pos = diff_pos.rotated(Vector3(0,0,1), diff_rot.z)
		child.global_position = diff_pos + origin
		child.scale_object_local(old_scl)

func update_scale(updated_scl : Vector3):
	scale = Vector3.ONE
	scale_object_local(updated_scl)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(parents)
	print(get_children())
	CollisionMesh = find_child("Collider", true, false)
	print(CollisionMesh)
	if CollisionMesh == null:
		printerr("Warning: ", name, " failed to init CollisionMesh var")
	VisualMesh = find_child("VisMesh3D", true, false)
	print(VisualMesh)
	if VisualMesh == null:
		printerr("Warning: ", name, " failed to init VisualMesh var")
	if len(parents) > 0:
		update_position_recursive(parents[0].global_position)

func propagate_part_deletion():
	for child in children:
		child.propagate_part_deletion()
	if not prepare_delete():
		printerr(self, " failed propagate_part_deletion")
