# File: enemy.gd
extends CharacterBody3D

# Constants
const GRAVITY: float = -9.8
const PUSH_FORCE: float = 5.0
const MAX_FALL_SPEED: float = -20.0
const DECELERATION: float = 5.0
var HIT_TIMER: float = 0.0
const HIT_COOLDOWN: float = 0.5
const JUMP_DISTANCE = 5.0
const JUMP_COOLDOWN: float = 3.0
@export var JUMP_TIMER: float = 0.0
var jumping = false

var player: Node3D = null

func _ready() -> void:
	# Find the player node in the scene (adjust the path as necessary)
	player = get_tree().root.get_node("Game/Pleijeri")
var hp = 100

func damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
func heal(amount):
	hp += amount

# Called when the physics engine updates (every physics frame)
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = max(velocity.y, MAX_FALL_SPEED)  # Limit fall speed
		if position.y <= -15:
			queue_free()
		
	else:
		if !jumping:
			velocity.y = 0
		jumping = false
		#position.y += 0.001
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * max(velocity.length() - DECELERATION * delta, 0)
	# Move and slide along surfaces (use move_and_slide with no arguments)
	move_and_slide()
	HIT_TIMER += delta
	# Check for collisions with other bodies
	
	# Countdown to next jump
	JUMP_TIMER += delta
	if JUMP_TIMER >= JUMP_COOLDOWN and player:
		# Jump towards the player
		jump_towards_player()
		JUMP_TIMER = 0.0  # Reset the jump timer

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "killplane":
			queue_free()
		elif collider.name.contains("Bullet"):
			collider.queue_free()
			damage(50)
		elif collider.name.contains("pool"):
			if HIT_TIMER > HIT_COOLDOWN:
				print("hit acid")
				velocity.y += 20
				damage(25)
				HIT_TIMER = 0.0
		elif collider.name != "mappi":
			if HIT_TIMER > HIT_COOLDOWN:
				# Apply push force based on collision normal
				apply_knockback(collider)
				HIT_TIMER = 0.0

func jump_towards_player() -> void:
	if player:
		# Calculate direction towards player
		var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
			
			# Set the horizontal velocity towards the player
		velocity.x = direction_to_player.x * JUMP_DISTANCE
		velocity.z = direction_to_player.z * JUMP_DISTANCE
		velocity.y = JUMP_DISTANCE
		jumping = true


# Function to apply knockback to the player
func apply_knockback(player: Node3D) -> void:
	if player is CharacterBody3D:
		var knockback_direction = (player.global_transform.origin - global_transform.origin).normalized()
		knockback_direction.y = max(knockback_direction.y, 0.75)

		player.velocity += knockback_direction * PUSH_FORCE  # Apply knockback force
		velocity += -knockback_direction * PUSH_FORCE
		player.damage(5)
