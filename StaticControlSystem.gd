extends "res://RobotPartController.gd"

@export var children_to_control = []

@export var control_type : CustomDatatypes.ControlTypes = CustomDatatypes.ControlTypes.TYPE_NULL

@export var control_map = {
	CustomDatatypes.States.CTRL_NULL : 0, 
	CustomDatatypes.States.CTRL_STOP : 0, 
	CustomDatatypes.States.CTRL_FWD : 1, 
	CustomDatatypes.States.CTRL_REV : -1
}

const SPEED = 60 

var old_state = 0
var current_state = 0

func _physics_process(_delta):
	if control_type == CustomDatatypes.ControlTypes.TYPE_CONTROLLER:
		old_state = current_state
		if Input.is_action_pressed("control_fwd"):
			current_state = CustomDatatypes.States.CTRL_FWD
			if current_state != old_state:
				print("fwd")
		elif Input.is_action_pressed("control_rev"):
			current_state = CustomDatatypes.States.CTRL_REV
			if current_state != old_state:
				print("rev")
		else:
			current_state = CustomDatatypes.States.CTRL_STOP
		
		if old_state != current_state:
			for child in children_to_control:
				child.set_motor_state(current_state)

func set_motor_state(state : CustomDatatypes.States):
	properties["axle"].set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, SPEED * control_map[state])
	properties["axle"].set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
