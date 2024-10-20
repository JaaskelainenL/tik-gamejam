# File: collectible.gd
extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Pleijeri":
		body.damage(-50)
		queue_free()  # Remove the collectible from the scene.
