extends CharacterBody3D

const FORCE: float = 4
const YAW_AMOUNT: float = 1.0

var thrust_forward: float = 0
var gravity: float
var _rotation_previous: Vector3
@export var linear_damp_amount: float

func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("thrust_forward"):
		if event is InputEventJoypadButton:
			thrust_forward = 1
		if event is InputEventJoypadMotion:
			print(event.axis_value)
			thrust_forward = event.axis_value
	
	if event.is_action_released("thrust_forward"):
		if event is InputEventJoypadButton:
			return
		if event is InputEventJoypadMotion:
			return
#yaw
#pitch

func _physics_process(delta: float) -> void:
	if thrust_forward > 0:
		velocity = Vector3(thrust_forward * FORCE * -1, thrust_forward * FORCE * -1, thrust_forward * FORCE * -1) * basis.z
	var yaw_axis: float = Input.get_axis("yaw_left", "yaw_right") * YAW_AMOUNT
	var pitch_axis: float = Input.get_axis("pitch_forward", "pitch_backward") * YAW_AMOUNT
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_axis * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_axis * delta)
	transform.basis = transform.basis.orthonormalized()
	rotation.z = 0
	#	apply_central_force(Vector3(thrust_forward * FORCE * -1, gravity, thrust_forward * FORCE * -1) * basis.z)\
	
	move_and_slide()
	
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	## Rotate yaw
	var yaw_axis: float = Input.get_axis("yaw_left", "yaw_right") * YAW_AMOUNT
	state.transform = state.transform.rotated_local(Vector3.DOWN, yaw_axis)
	## Rotate pitch
	#var pitch_axis: float = Input.get_axis("pitch_forward", "pitch_backward") * YAW_AMOUNT
	#state.transform = state.transform.rotated_local(Vector3.MODEL_LEFT, pitch_axis)
	#
	#print(state.linear_velocity)
#
#
	#_rotation_previous = rotation
