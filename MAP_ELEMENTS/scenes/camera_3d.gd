extends Camera3D

@export var follow_speed: float = 5.0

var player: Node3D
var initial_offset: Vector3

func _ready() -> void:
	# Get the Player node directly as a sibling
	player = get_parent().get_node("Player")
	
	# Calculate the initial offset from the player’s position
	if player:
		initial_offset = global_transform.origin - player.global_transform.origin

func _process(delta: float) -> void:
	if not player:
		return

	# Calculate the target position based on the player's position and initial offset
	var target_position = player.global_transform.origin + initial_offset
	
	# Smoothly move the camera position towards the target position
	global_transform.origin = global_transform.origin.lerp(target_position, follow_speed * delta)
