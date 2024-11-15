extends Node3D

var cached_vertices: Array = []

func _ready() -> void:
	cache_navigation_mesh_vertices()

func cache_navigation_mesh_vertices() -> void:
	var navigation_mesh = $NavigationRegion3D.navigation_mesh
	cached_vertices = navigation_mesh.get_vertices()
	if cached_vertices.size() == 0:
		print("Navigation mesh has no vertices!")

func get_random_roaming_position(mob_position: Vector3, radius: float) -> Vector3:
	var navigation_mesh = $NavigationRegion3D.navigation_mesh
	var vertices = navigation_mesh.get_vertices()
	
	if vertices.size() == 0:
		print("Navigation mesh has no vertices!")
		return global_transform.origin  # Fallback position

	# Filter vertices based on distance to the mob
	var nearby_vertices = []
	for vertex in vertices:
		var world_vertex = $NavigationRegion3D.to_global(vertex)
		if mob_position.distance_to(world_vertex) <= radius:
			nearby_vertices.append(world_vertex)
	
	if nearby_vertices.size() == 0:
		print("No nearby vertices found within the radius.")
		return global_transform.origin  # Fallback position
	
	# Select a random vertex from the filtered list
	var random_index = randi() % nearby_vertices.size()
	return nearby_vertices[random_index]
