extends RigidBody3D

# Speed of the bullet
@export var speed: float = 10.0
var age = 0.0
const MAX_AGE = 5.0
var direction: Vector3 = Vector3.ZERO

# Sets the direction for the bullet to move
func set_direction(dir: Vector3) -> void:
	direction = dir.normalized()

# Called every physics frame to update the bullet's movement
func _physics_process(delta: float) -> void:
	age += delta
	if direction != Vector3.ZERO:
		# Set the bullet's velocity in the given direction
		linear_velocity = direction * speed
	
	if age > MAX_AGE:
		queue_free()
