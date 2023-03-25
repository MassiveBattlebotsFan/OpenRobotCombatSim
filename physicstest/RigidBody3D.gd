extends RigidBody3D

@onready var wheel_rf = $HingeJoint3D
@onready var wheel_lf = $HingeJoint3D2
@onready var wheel_rr = $HingeJoint3D3
@onready var wheel_lr = $HingeJoint3D4

const SPEED = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var speeds = [0, 0, 0, 0]
	if Input.is_action_pressed("ui_up"):
		speeds = [100,-100,100,-100]
	if Input.is_action_pressed("ui_down"):
		speeds = [-100,100,-100,100]
	if Input.is_action_pressed("ui_left"):
		speeds = [-100,-100,-100,-100]
	if Input.is_action_pressed("ui_right"):
		speeds = [100,100,100,100]
	wheel_rf.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, speeds[0])
	wheel_lf.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, speeds[1])
	wheel_rr.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, speeds[2])
	wheel_lr.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, speeds[3])
