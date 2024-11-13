extends Node3D

@export var target: Node3D  # The target that the mob will chase
@export var selected_mob_type: int = 0  # The selected mob type (0 for Mob1, 1 for Mob2, etc.)
@export var mob_types: Array = []  # Array of the child CharacterBody3D mobs

func _ready():
	# Automatically fill the mob_types array with all CharacterBody3D children
	mob_types.clear()  # Clear the array in case it's already populated
	for child in get_children():
		if child is CharacterBody3D:
			mob_types.append(child)  # Add each CharacterBody3D child to the array
	
	# Hide all the mobs initially
	for mob in mob_types:
		mob.visible = false  # Set visibility to false for all mobs
	
	# Make the selected mob visible based on selected_mob_type
	if selected_mob_type >= 0 and selected_mob_type < mob_types.size():
		var selected_mob = mob_types[selected_mob_type]
		selected_mob.visible = true  # Set the chosen mob to be visible

	# Set the target for the selected mob
	for mob in mob_types:
		if mob.has_method("set_target"):
			mob.set_target(target)  # Call a method to set the target for each mob
