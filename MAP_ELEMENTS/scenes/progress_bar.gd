extends ProgressBar

@onready var player = $"../../../Player_node/Player"

func _ready() -> void:
	self.max_value = player.health


func _process(delta: float) -> void:
	self.value = player.health
	
