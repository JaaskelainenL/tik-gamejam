extends StaticBody3D


@onready var colShape = $mappi/Collisionshape3D
@export var chunk_size = 100.0
@export var height_ratio = 1.0
@export var colShape_size_ratio = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
