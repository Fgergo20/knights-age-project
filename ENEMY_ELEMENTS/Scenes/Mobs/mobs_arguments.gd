extends Node3D

@export var target: Node3D = null
@export var tpye: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var character_body
	match tpye:
		0:
			character_body = get_node("Scorpio_man_mob")
		1:
			character_body = get_node("Grass_giant_mob")
		2:
			character_body = get_node("Ice_giant_mob")
		3:
			character_body = get_node("Wolf_Mob")
			
	character_body.set("visible", true)		
	
	$Bab.set("visible", false)
	$Bab.process_mode = $Bab.PROCESS_MODE_DISABLED
	
	if character_body and target:
		character_body.target = target
	character_body.process_mode = character_body.PROCESS_MODE_INHERIT
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
