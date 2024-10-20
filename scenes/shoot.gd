# File: collectible.gd
extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Pleijeri":
		%Pleijeri.items.append("shoot")
		%Pleijeri.BULLETS += 5
		print(str(%Pleijeri.items))
		queue_free()  # Remove the collectible from the scene.
