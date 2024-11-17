extends Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure there's an AnimationPlayer node attached.
	if not $AnimationPlayer:
		print("No AnimationPlayer found. Please add one as a child of the camera.")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if the 'ui_Cinematic' action is pressed
	if Input.is_action_just_pressed("ui_Cinematic"):
		play_cinematic()

func play_cinematic() -> void:
	# Play the animation if the AnimationPlayer exists
	if $AnimationPlayer:
		$AnimationPlayer.play("Camera_anim2")  # Replace 'YourAnimationName' with the name of your animation
	else:
		print("No AnimationPlayer attached or animation not found.")
