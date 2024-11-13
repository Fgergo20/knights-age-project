extends CharacterBody3D

@export var target: Node3D  # The target node to move towards.
@onready var navigation_agent = $NavigationAgent3D
@onready var navigation = get_node("/root/Navigation3D")  # Make sure to assign a proper navigation node.

# Gravity settings
var gravity = 9.8
var velocity = Vector3.ZERO

# Path visualization
var path = []

func _ready():
	# Initialize the navigation agent
	navigation_agent.agent_radius = 0.5
	navigation_agent.max_slope_angle = 45  # Adjust for your terrain
	navigation_agent.height = 2.0  # Adjust based on character height
	
	# Initial path calculation
	calculate_path()

func _process(delta):
	if target:
		# Update path if target is moved
		if target.position != navigation_agent.target_position:
			calculate_path()

		# Update the agent's velocity to move towards the target
		if path.size() > 0:
			var next_point = path[0]
			var direction = (next_point - global_position).normalized()
			velocity = direction * 5  # Adjust speed here

			# Apply gravity
			velocity.y -= gravity * delta

			# Move the character
			move_and_slide(velocity, Vector3.UP)
			
			# If close to the next point, pop it from the path
			if global_position.distance_to(next_point) < 1:
				path.remove(0)
				
		# Visualize the path (for debugging purposes)
		draw_path()

# Function to calculate the path from the current position to the target
func calculate_path():
	path = navigation_agent.get_simple_path(global_position, target.global_position)
	if path.size() > 0:
		# Remove the start point since it's not part of the path
		path.remove(0)

# Function to visualize the path
func draw_path():
	for i in range(path.size() - 1):
		var start = path[i]
		var end = path[i + 1]
		# Draw a line from start to end
		draw_line(start, end, Color(1, 0, 0), 2)  # Red lines, adjust thickness as needed
