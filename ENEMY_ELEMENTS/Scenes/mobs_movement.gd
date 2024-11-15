extends CharacterBody3D

@export var target: Node3D = null  # The target to follow, e.g., another CharacterBody3D or Player
@export var follow_distance: float = 10.0  # Distance to start following the target
@export var speed: float = 1.0  # Speed when moving
@export var roaming_range: float = 15.0  # Range within which the character can roam
@export var idle_duration: float = 3.0  # Time to stay idle before roaming again
@export var wall_avoidance_distance: float = 2.0  # Distance to maintain from walls
@export var rotation_speed: float = 5.0  # Adjust for smoothness

@export var health: float = 100.0
@export var close_range: float = 6.0
@export var attack_range: float = 5.0
@export var attack_damage: float = 10.0
@export var death_time: float = 3.0
@export var attack_time: float = 1.5
@export var gravity: float = -9.8

@export var follow_to_idle_delay: float = 1.0  # Delay before switching from FOLLOW to IDLE
@export var idle_to_follow_delay: float = 1.0  # Delay before switching from IDLE to FOLLOW

var state_timer: float = 0.0  # Timer to track state delay
var attack_cooldown_timer: float = 0.0

enum State { IDLE, FOLLOW, ROAM }
var current_state: State = State.IDLE

var navigation_agent: NavigationAgent3D
var idle_timer: float = 0.0
var roaming_target: Vector3
var raycast: RayCast3D

var animation_tree: AnimationTree
var is_attacking: bool = false
var is_dead: bool = false

func _ready():
	navigation_agent = $NavigationAgent3D
	raycast = RayCast3D.new()
	raycast.target_position = Vector3(wall_avoidance_distance, 0, 0)
	raycast.enabled = true
	add_child(raycast)
	
	animation_tree = get_node("AnimationTree")
	if animation_tree:
		animation_tree.active = true
		set_animation_blend("Walk", 0.0)
		set_animation_blend("Attack", 0.0)
		set_animation_blend("Dead", 0.0)
	else:
		print("Error: AnimationTree not found for instance.")

func _physics_process(delta):
	state_timer += delta
	
	var target_node = target
	var target_position = target_node.global_transform.origin if target_node else null

	# Check if target's health is below 1 to make the mob idle
	#if target and target.health < 1:
		#if current_state != State.IDLE:
			#print("buzi")#change_state(State.IDLE)
	#else:
		# Decide on the next state based on distance and state timer
	if target and target.health > 0 and target_position and global_transform.origin.distance_to(target_position) < follow_distance:
		if current_state == State.IDLE and state_timer >= idle_to_follow_delay:
			change_state(State.FOLLOW)
	else:
		if current_state == State.FOLLOW and state_timer >= follow_to_idle_delay:
			change_state(State.IDLE)

	match current_state:
		State.IDLE:
			handle_idle_state(delta, target_position)
		State.FOLLOW:
			handle_follow_state(delta, target_position)
		State.ROAM:
			handle_roam_state(delta)

	update_animation_state(delta)
	
	if target.health > 0:
		check_for_attack()
	else:
		is_attacking = false
		
	check_for_death()

# Change state and reset the timer
func change_state(new_state: State):
	#if current_state != new_state:
		#print("State changed to:", new_state)  # Print the state whenever it changes
	current_state = new_state
	state_timer = 0.0  # Reset the timer when switching states



func handle_idle_state(delta, target_position):
	idle_timer += delta
	if target.health > 0 and target_position and global_transform.origin.distance_to(target_position) < follow_distance:
		current_state = State.FOLLOW
	elif idle_timer >= idle_duration:
		if current_state != State.ROAM:
			start_roaming()
		

func handle_follow_state(delta, target_position):
	if target_position:
		if global_transform.origin.distance_to(target_position) < follow_distance:
			navigation_agent.target_position = target_position
			if not navigation_agent.is_navigation_finished():
				var next_position = navigation_agent.get_next_path_position()
				var target_direction = (next_position - global_transform.origin).normalized()

				# Calculate the desired rotation angle in the Y plane
				var target_rotation_y = atan2(target_direction.x, target_direction.z)
				
				# Smoothly interpolate the character's Y rotation
				var current_rotation_y = rotation.y
				rotation.y = lerp_angle(current_rotation_y, target_rotation_y, rotation_speed * delta)

				velocity = target_direction * speed
				avoid_walls()  # Apply wall avoidance here
				move_and_slide()
			else:
				velocity = Vector3.ZERO
		else:
			current_state = State.IDLE
			idle_timer = 0.0
			velocity = Vector3.ZERO

func handle_roam_state(delta):
	# Check if we have reached the roaming target
	if global_transform.origin.distance_to(roaming_target) < close_range:
		# Switch to IDLE once target is reached
		change_state(State.IDLE)
		idle_timer = 0.0
		velocity = Vector3.ZERO  # Stop movement when idle
	else:
		# Continue moving towards the current roaming target
		navigation_agent.target_position = roaming_target
		if not navigation_agent.is_navigation_finished():
			var next_position = navigation_agent.get_next_path_position()
			var target_direction = (next_position - global_transform.origin).normalized()

			# Calculate the desired rotation angle in the Y plane
			var target_rotation_y = atan2(target_direction.x, target_direction.z)
			
			# Smoothly interpolate the character's Y rotation
			var current_rotation_y = rotation.y
			rotation.y = lerp_angle(current_rotation_y, target_rotation_y, rotation_speed * delta)

			# Set movement velocity
			velocity = target_direction * speed
			#avoid_walls()  # Apply wall avoidance
			move_and_slide()



func start_roaming():
	# Set a new roaming target only once when starting to roam
	roaming_target = call_random_roaming_position_from_root()
	change_state(State.ROAM)



func call_random_roaming_position_from_root() -> Vector3:
	# Assuming the root node is accessible as `Main_LAND`
	#var main_land = get_tree().root.get_node("Main_LAND")
	
	# Get the mob's current position
	var mob_position = global_transform.origin
	
	# Define the desired roaming radius
	var roaming_radius = 10.0  # Adjust this value as needed
	
	# Call the function with mob position and radius
	return get_tree().root.get_node("Main_LAND").get_random_roaming_position(mob_position, roaming_radius)






func avoid_walls():
	# Adjusts movement direction if there's a nearby wall detected by RayCast3D
	raycast.global_transform.origin = global_transform.origin
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var normal = (global_transform.origin - collision_point).normalized()
		
		# Apply a small perpendicular offset to velocity to steer away from the wall
		velocity += normal * 0.2 * speed
		
# Main function to update animations based on the character's state
func update_animation_state(delta: float):
	if is_dead:
		blend_to_animation("Dead", delta)
	elif is_attacking:
		blend_to_animation("Attack", delta)
	else:
		if current_state == State.IDLE:
			# Smoothly reduce the Walk blend amount to 0 when in the IDLE state
			smooth_blend("parameters/Walk/blend_amount", 0.0, delta)
		elif current_state == State.FOLLOW || current_state == State.ROAM:
			# Smoothly increase the Walk blend amount if in FOLLOW state
			blend_to_animation("Walk", delta)

# Sets blend amount for a specific animation parameter
func set_animation_blend(animation_name: String, value: float):
	var param_path = "parameters/%s/blend_amount" % animation_name
	animation_tree.set(param_path, value)

# Smoothly transitions to a specified animation using linear interpolation
func blend_to_animation(animation_name: String, delta: float):
	@warning_ignore("shadowed_variable_base_class")
	for name in ["Walk", "Attack", "Dead"]:
		var target_blend = 1.0 if name == animation_name else 0.0
		smooth_blend("parameters/%s/blend_amount" % name, target_blend, delta)


# Smoothly interpolates a blend amount to a target value
func smooth_blend(param_path: String, target_value: float, delta: float):
	var current_value = animation_tree.get(param_path)
	var blend_speed = 2.0  # Speed of blending
	var new_value = lerp(current_value, target_value, blend_speed * delta)
	animation_tree.set(param_path, new_value)

# Call this function to trigger an attack animation
func trigger_attack():
	is_attacking = true
	reset_animation("Attack")
	set_animation_blend("Attack", 1.0)

	target.health -= attack_damage  # Apply damage after delay
	attack_cooldown_timer = 1
	print(target.health)
	# Reset attack state after attack time
	await get_tree().create_timer(attack_time).timeout
	is_attacking = false
	attack_cooldown_timer = 0
	if !target.health > 0:
		start_roaming()
		#print("kocsog")
	

# Call this function to trigger a death animation
func trigger_death():
	is_dead = true
	reset_animation("Dead")
	set_animation_blend("Dead", 1.0)

	# Delay before freeing the node
	await get_tree().create_timer(death_time).timeout
	queue_free()

# Resets a specific animation to the beginning
func reset_animation(animation_name: String):
	var reset_param = "parameters/%s_reset/seek_request" % animation_name
	animation_tree.set(reset_param, 0.0)
	
func check_for_attack():
	if attack_cooldown_timer == 0  and target and global_transform.origin.distance_to(target.global_transform.origin) <= attack_range:
		trigger_attack()

func check_for_death():
	if health <= 0:
		trigger_death()
