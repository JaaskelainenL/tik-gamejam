extends Area3D

# Called when a body enters the Area3D
func _on_body_entered(body: Node3D) -> void:
	print("hit")

	# Check if the body has a velocity property
	if body.has_method("move_and_slide"):
		body.velocity.y = 20  # Apply bounce by modifying Y velocity
		body.hp -= 20
