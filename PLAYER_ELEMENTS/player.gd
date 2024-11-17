extends CharacterBody3D

const MAX_SPEED = 5.0
const ACCELERATION = 3.0  # Controls how quickly you reach max speed
const DECELERATION = 5.0  # Controls how quickly you slow down
const ROTATION_SPEED = 5.0  # Controls the smoothness of rotation
const JUMP_VELOCITY = 4.5
const BLEND_SPEED = 5.0  # Controls how quickly blend amounts change

var health = 10000  # Example health variable
var damage = 80

# Animation tree and blend parameters
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var camera = get_parent().get_node("Camera3D")
@onready var area = $Area3D  # Reference to your Area3D node

var mob_names = ["Scorpio_man_mob", "Grass_giant_mob", "Wolf_Mob", "Ice_giant_mob"]  # Example mob names
var mobs_in_area = []  # List to track the mobs inside the Area3D during attack

func damage_mob(mob: Node) -> void:
	if mob is CharacterBody3D:
		mob.health -= damage  # Apply 10 damage to the mob (adjust as needed)
		create_label3d(str(damage), Vector3(0, 2.5, 0), 50, Color(1.0, 1.0, 0.0, 1.0))
		print(mob.name + " took damage!")

# Animation blend values
var run_blend = 0.0
var attack_blend = 0.0
var dead_blend = 0.0

func _ready():
	animation_tree.active = true
	area.connect("body_entered", Callable(self, "_on_area_body_entered"))
	area.connect("body_exited", Callable(self, "_on_area_body_exited"))

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
	if Input.is_action_just_pressed("ui_attack"):
		attack_blend = 1.0
		run_blend = 0.0
		
		# Damage mobs in area
		for mob in mobs_in_area:
			if mob_names.has(mob.name):  # Check if the mob's name is in the list
				damage_mob(mob)

		# Clear the mobs_in_area list after attack
		

	elif Input.is_action_just_released("ui_attack"):
		attack_blend = lerp(attack_blend, 0.0, BLEND_SPEED * delta)
		
	# Apply updated blend values to the AnimationTree
	animation_tree.set("parameters/Run/blend_amount", run_blend)
	animation_tree.set("parameters/Attack/blend_amount", attack_blend)

	move_and_slide()

func _on_area_body_entered(body: Node) -> void:
	print(body.name)
	if body is CharacterBody3D and mob_names.has(body.name):
		mobs_in_area.append(body)  # Add mob to the list when it enters the area

func _on_area_body_exited(body: Node) -> void:
	if body is CharacterBody3D and mob_names.has(body.name):
		mobs_in_area.erase(body)  # Remove mob from the list when it exits the area

func create_label3d(label_text: String, label_position: Vector3, font_size: int, color: Color) -> Label3D:
	var label = Label3D.new()
	label.text = label_text
	label.font_size = font_size
	label.render_priority = 3
	label.billboard = 1
	var g_p = label_position + Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	label.set("modulate", color)
	label.set("position", g_p)
	label.set("scale", Vector3(2,2,2))
	add_child(label)
	# Create a Tween node for animation
	var tween = get_tree().create_tween()
	
	tween.tween_property(label, "scale", Vector3(), 1)
	tween.tween_callback(label.queue_free)
	await get_tree().create_timer(1.0).timeout
	return label
