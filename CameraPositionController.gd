extends Node3D

# Robot editor camera position controller


signal part_selected(node_reference)
signal part_placed(hover_target)

const DEBUG = false
const ROT_SPEED = 0.01
const VERT_ROT_LIMIT = PI/2
const ZOOM_STEP = 0.1
const MAX_ZOOM = 0.2
const MIN_ZOOM = 10
const RAYCAST_LEN = 30

var camera_rot = Vector2(0,0)
var hover_target = null
var event_cache = null

@onready var MainCamera = $MainCamera
@onready var Raycast = $MainCamera/RayCast3D
@onready var Cursor = $MeshInstance3D
@onready var RobotConstruction = $"../RobotConstruction"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func raycast_handler(event):
	var to = MainCamera.project_local_ray_normal(event.position)
	Raycast.target_position = to * RAYCAST_LEN
	if DEBUG:
		print("to: ", to)
	Raycast.force_raycast_update()
	if DEBUG:
		print("is_colliding: ", Raycast.is_colliding())
	if Raycast.is_colliding():
		hover_target = Raycast.get_collider()
		#print("target: ", hover_target, " pos: ", hover_target.global_position)
		Cursor.global_position = Raycast.get_collision_point()
		Cursor.show()
	else:
		hover_target = null
		Cursor.hide()

func _input(event):
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		# modify accumulated mouse rotation
		camera_rot.x += event.relative.x * -ROT_SPEED
		camera_rot.y += event.relative.y * -ROT_SPEED
		transform.basis = Basis() # reset rotation
		camera_rot.y = clampf(camera_rot.y, -VERT_ROT_LIMIT, VERT_ROT_LIMIT);
		rotate_object_local(Vector3(0, 1, 0), camera_rot.x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), camera_rot.y) # then rotate in X
	if event is InputEventMouse:
		event_cache = event
		raycast_handler(event)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and hover_target != null:
			print("selected ", hover_target)
			if RobotConstruction.active_placeable_part["mesh"][0] != null:
				print("emitting part_placed")
				emit_signal("part_placed", hover_target)
			else:
				print("emitting part_selected")
				emit_signal("part_selected", hover_target)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and MainCamera.position.z < MIN_ZOOM:
			MainCamera.translate_object_local(Vector3(0, 0, ZOOM_STEP))
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and MainCamera.position.z > MAX_ZOOM:
			MainCamera.translate_object_local(Vector3(0, 0, -ZOOM_STEP))


func _on_robot_construction_part_list_update_items(add, node_reference):
	if event_cache != null:
		raycast_handler(event_cache)
