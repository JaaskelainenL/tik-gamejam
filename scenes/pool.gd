extends RigidBody3D

var age = 0.0
const MAX_AGE = 20.0

# Called every physics frame to update the bullet's movement
func _physics_process(delta: float) -> void:
	age += delta

	if age > MAX_AGE:
		queue_free()
