extends CharacterBody3D

const MAX_SPEED = 5.0
const ACCELERATION = 3.0  # Controls how quickly you reach max speed
const DECELERATION = 5.0  # Controls how quickly you slow down
const ROTATION_SPEED = 5.0  # Controls the smoothness of rotation
const JUMP_VELOCITY = 4.5
const BLEND_SPEED = 5.0  # Controls how quickly blend amounts change

var health = 100  # Example health variable

# Animation tree and blend parameters
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var camera = get_parent().get_node("Camera3D")

# Animation blend values
var run_blend = 0.0
var attack_blend = 0.0
var dead_blend = 0.0

func _ready():
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	# Prevent movement if health is 0 or below
	if health <= 0:
		# Set Dead blend to 1 smoothly, and ensure other animations are zero
		dead_blend = lerp(dead_blend, 1.0, BLEND_SPEED * delta)
		run_blend = lerp(run_blend, 0.0, BLEND_SPEED * delta)
		attack_blend = lerp(attack_blend, 0.0, BLEND_SPEED * delta)

		# Apply the updated blends to the AnimationTree
		animation_tree.set("parameters/Dead/blend_amount", dead_blend)
		animation_tree.set("parameters/Run/blend_amount", run_blend)
		animation_tree.set("parameters/Attack/blend_amount", attack_blend)
		return  # Skip movement logic

	# Add gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Get the input direction and adjust it based on camera orientation
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Transform input based on camera's orientation
	var cam_forward = camera.transform.basis.z
	var cam_right = camera.transform.basis.x
	var direction = (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()

	# Smooth acceleration and deceleration for movement
	if direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * MAX_SPEED, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * MAX_SPEED, ACCELERATION * delta)

		# Calculate the target rotation angle
		var target_rotation_y = atan2(-direction.x, -direction.z)

		# Smoothly interpolate to the target rotation
		rotation.y = lerp_angle(rotation.y, target_rotation_y, ROTATION_SPEED * delta)

		# Set Run blend smoothly to 1 if moving and Attack to 0
		run_blend = lerp(run_blend, 1.0, BLEND_SPEED * delta)
		attack_blend = lerp(attack_blend, 0.0, BLEND_SPEED * delta)
	else:
		# Decelerate when no input and reduce the Run blend smoothly to 0
		velocity.x = lerp(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = lerp(velocity.z, 0.0, DECELERATION * delta)
		run_blend = lerp(run_blend, 0.0, BLEND_SPEED * delta)

	# Handle attack input
	if Input.is_action_just_pressed("ui_attack"):  # Replace with your actual attack input
		attack_blend = 1.0
		run_blend = 0.0
	elif Input.is_action_just_released("ui_attack"):
		attack_blend = lerp(attack_blend, 0.0, BLEND_SPEED * delta)

	# Apply updated blend values to the AnimationTree
	animation_tree.set("parameters/Run/blend_amount", run_blend)
	animation_tree.set("parameters/Attack/blend_amount", attack_blend)

	move_and_slide()
