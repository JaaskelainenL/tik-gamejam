# File: collectible.gd
extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Pleijeri":
		%Pleijeri.items.append("shoot")
		print(str(%Pleijeri.items))
		queue_free()  # Remove the collectible from the scene.
