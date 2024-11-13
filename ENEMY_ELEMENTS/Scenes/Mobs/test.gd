extends CharacterBody3D

@export var target: NodePath  # The target to follow, e.g., another CharacterBody3D or Player
@export var follow_distance: float = 10.0  # Distance to start following the target
@export var speed: float = 1.0  # Speed when moving
@export var roaming_range: float = 15.0  # Range within which the character can roam
@export var idle_duration: float = 3.0  # Time to stay idle before roaming again
@export var wall_avoidance_distance: float = 2.0  # Distance to maintain from walls

enum State { IDLE, FOLLOW, ROAM }
var current_state: State = State.IDLE

var navigation_agent: NavigationAgent3D
var idle_timer: float = 0.0
var roaming_target: Vector3
var raycast: RayCast3D

func _ready():
	navigation_agent = NavigationAgent3D.new()
	add_child(navigation_agent)
	navigation_agent.target_desired_distance = 0.5  # Fine-tune for smoother stops

	# Initialize RayCast3D for wall detection
	raycast = RayCast3D.new()
	raycast.target_position = Vector3(wall_avoidance_distance, 0, 0)  # Corrected to target_position
	raycast.enabled = true
	add_child(raycast)

func _physics_process(delta):
	var target_node = get_node_or_null(target)
	var target_position = target_node.global_transform.origin if target_node else null

	match current_state:
		State.IDLE:
			handle_idle_state(delta, target_position)
		State.FOLLOW:
			handle_follow_state(delta, target_position)
		State.ROAM:
			handle_roam_state(delta)

func handle_idle_state(delta, target_position):
	idle_timer += delta
	if target_position and global_transform.origin.distance_to(target_position) < follow_distance:
		current_state = State.FOLLOW
	elif idle_timer >= idle_duration:
		start_roaming()

func handle_follow_state(delta, target_position):
	if target_position:
		if global_transform.origin.distance_to(target_position) < follow_distance:
			navigation_agent.target_position = target_position
			if not navigation_agent.is_navigation_finished():
				var direction = (navigation_agent.get_next_path_position() - global_transform.origin).normalized()
				velocity = direction * speed
				avoid_walls()  # Apply wall avoidance here
				move_and_slide()
			else:
				velocity = Vector3.ZERO
		else:
			current_state = State.IDLE
			idle_timer = 0.0
			velocity = Vector3.ZERO

func handle_roam_state(delta):
	if global_transform.origin.distance_to(roaming_target) < 1.0:
		current_state = State.IDLE
		idle_timer = 0.0
	else:
		navigation_agent.target_position = roaming_target
		if not navigation_agent.is_navigation_finished():
			var direction = (navigation_agent.get_next_path_position() - global_transform.origin).normalized()
			velocity = direction * speed
			avoid_walls()  # Apply wall avoidance here
			move_and_slide()

func start_roaming():
	roaming_target = get_random_roaming_position()
	current_state = State.ROAM

func get_random_roaming_position() -> Vector3:
	var random_offset = Vector3(
		randf_range(-roaming_range, roaming_range),
		0,
		randf_range(-roaming_range, roaming_range)
	)
	return global_transform.origin + random_offset

func avoid_walls():
	# Adjusts movement direction if there's a nearby wall detected by RayCast3D
	raycast.global_transform.origin = global_transform.origin
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var normal = (global_transform.origin - collision_point).normalized()
		
		# Apply a small perpendicular offset to velocity to steer away from the wall
		velocity += normal * 0.2 * speed
