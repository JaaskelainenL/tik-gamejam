# File: enemy.gd
extends CharacterBody3D

# Constants
const GRAVITY: float = -9.8
const PUSH_FORCE: float = 10.0
const MAX_FALL_SPEED: float = -20.0
const DECELERATION: float = 2.0
var HIT_TIMER: float = 0.0
const HIT_COOLDOWN: float = 0.5

# Called when the physics engine updates (every physics frame)
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = max(velocity.y, MAX_FALL_SPEED)  # Limit fall speed
	else:
		position.y += 0.001
		velocity.y = 0  # Reset Y velocity when on the floor
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * max(velocity.length() - DECELERATION * delta, 0)
	# Move and slide along surfaces (use move_and_slide with no arguments)
	move_and_slide()
	HIT_TIMER += delta
	# Check for collisions with other bodies

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.name != "floor":
			print("hit")
			if HIT_TIMER > HIT_COOLDOWN:
				# Apply push force based on collision normal
				var push_direction = collision.get_normal() * PUSH_FORCE
				
				velocity += push_direction
				HIT_TIMER = 0.0
