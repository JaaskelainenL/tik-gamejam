extends Node3D

const ENEMY_COUNT = 5
var enemy = preload("res://scenes/enemy.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(ENEMY_COUNT):
		# Instance the model
		var instance = enemy.instantiate() as CharacterBody3D
		
		# Add the instance to the scene tree, under this node
		add_child(instance)
		
		# Set a random position or custom placement for each instance
		instance.global_position = Vector3(randf() * 10.0, 0.0, randf() * 10.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
