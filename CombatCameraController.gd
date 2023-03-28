extends Camera3D

@export var ID = 0
@onready var RobotConstruction = $"../RobotConstruction"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if RobotConstruction != null:
		look_at(RobotConstruction.Origin.global_position, Vector3.UP)
