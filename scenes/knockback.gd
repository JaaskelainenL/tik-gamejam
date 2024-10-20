extends Area3D

# Minimum and maximum reactivation time in seconds
const MIN_REACTIVATION_TIME: float = 10.0
const MAX_REACTIVATION_TIME: float = 60.0

# Timer for reactivating the acid pool
var reactivation_timer: Timer = null

func _ready() -> void:
	# Create a timer to handle reactivation
	reactivation_timer = Timer.new()
	reactivation_timer.one_shot = true  # It should only fire once
	reactivation_timer.connect("timeout", Callable(self, "_on_reactivation_timeout"))  # Connect the timer signal
	add_child(reactivation_timer)  # Add the timer to the scene
	
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Pleijeri":
		%Pleijeri.items.append("knockback")
		print(str(%Pleijeri.items))
		# Make the acid pool invisible and disable it for further collection
		self.visible = false
		self.set_collision_layer(0)  # Disable collision
		self.set_collision_mask(0)   # Disable being detected
		
		# Generate a random time between MIN_REACTIVATION_TIME and MAX_REACTIVATION_TIME
		var random_reactivation_time = randf_range(MIN_REACTIVATION_TIME, MAX_REACTIVATION_TIME)
		
		# Set the timer's wait time to the randomly generated value
		reactivation_timer.wait_time = random_reactivation_time
		
		# Start the reactivation timer
		reactivation_timer.start()

# This function is called when the reactivation timer finishes
func _on_reactivation_timeout() -> void:
	# Make the acid pool visible again and re-enable collisions
	self.visible = true
	self.set_collision_layer(1)  # Enable collision
	self.set_collision_mask(1)   # Enable being detected
