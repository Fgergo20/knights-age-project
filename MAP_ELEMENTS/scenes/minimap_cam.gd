extends Camera3D

@export var _followScanRadius : float

@export var _playerTarget : NodePath
@onready var _target = get_node(_playerTarget)

@export var _playerRotationTarget : NodePath
@onready var _targetRotation = get_node(_playerRotationTarget)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = _followScanRadius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = Vector3(_target.position.x, 30, _target.position.z)
	rotation_degrees.y = _targetRotation.rotation_degrees.y
