extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Reference to the camera as a sibling
@onready var camera = get_parent().get_node("Camera3D")

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and adjust it based on camera orientation
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Transform input based on camera's orientation
	var cam_forward = camera.transform.basis.z
	var cam_right = camera.transform.basis.x
	var direction = (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
