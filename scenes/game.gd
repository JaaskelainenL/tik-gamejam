extends Node3D
var rng = RandomNumberGenerator.new()
const ENEMY_COUNT = 3
var enemy = preload("res://scenes/enemy.tscn") as PackedScene
@export var score = 0
@onready var player = get_tree().root.get_node("Game/Pleijeri")
@onready var scoreText = player.get_node("Camera3D/score_label")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(ENEMY_COUNT):
		# Instance the model
		var instance = enemy.instantiate() as CharacterBody3D
		
		# Add the instance to the scene tree, under this node
		add_child(instance)
		
		# Set a random position or custom placement for each instance
		instance.global_position = Vector3(rng.randf_range(-10.0,10.0) * player.position.x, 0.0, rng.randf_range(-10.0,10.0) * player.position.z)
		var enemy_script = instance.get_script() as Script
		if enemy_script and enemy_script.resource_path == "res://scenes/enemy.gd": # Adjust the path accordingly
			instance.JUMP_TIMER = rng.randf() * 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if there are fewer than 3 enemies
	if get_enemy_count() < ENEMY_COUNT:
		# Spawn more enemies if needed
		spawn_enemy()

# Function to spawn an enemy
func spawn_enemy() -> void:
	# Instance the enemy model
	var instance = enemy.instantiate() as CharacterBody3D
	# Add the instance to the scene tree, under this node
	add_child(instance)
	score+=1
	scoreText.text = "Score: "+str(score)

	# Set a random position or custom placement for each instance
	instance.global_position = Vector3(
		rng.randf_range(-10.0, 10.0) * player.position.x,
		0.0,
		rng.randf_range(-10.0, 10.0) * player.position.z
	)

	# Initialize enemy properties if the script is set up correctly
	var enemy_script = instance.get_script() as Script
	if enemy_script and enemy_script.resource_path == "res://scenes/enemy.gd": # Adjust the path accordingly
		instance.JUMP_TIMER = rng.randf() * 3.0

# Function to count the number of enemies
func get_enemy_count() -> int:
	var count = 0
	for child in get_children():
		if child is CharacterBody3D:
			count += 1
	return count
