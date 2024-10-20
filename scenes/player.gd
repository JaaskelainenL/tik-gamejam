extends CharacterBody3D

var pool = preload("res://scenes/pool.tscn") as PackedScene
const JUMP_DISTANCE = 7.0
const JUMP_HEIGHT = 4.5
const SPIN = 3.0

var hp = 100.0
@onready var hpText = get_node("Camera3D/hp_label")
@onready var abText = get_node("Camera3D/abilities_label")

var doing_action = false
var roulette_active = false
var roulette_instance = null
var items: Array[String] = []
# Movement speed on the ground
var speed: float = 5.0  # You can adjust this value
var HIT_TIMER: float = 0.0
const HIT_COOLDOWN: float = 0.5
var PUSH_FORCE: float = 20
var KB_USES = 0

func _process(delta: float) -> void:
	if is_on_floor() and !doing_action and !roulette_active:
		rotate_y(SPIN * delta)

func _physics_process(delta: float) -> void:
	HIT_TIMER += delta
	# Check if colliding with kill plane
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "killplane":
			print("you died")
			global_position = Vector3(0.0, 0.4, 0.0)
		elif collider.name.contains("CharacterBody3D"):  # Assuming enemy's name is "enemy"
			if HIT_TIMER > HIT_COOLDOWN:
				print("hit enemy")
				apply_knockback_to_enemy(collider)
				HIT_TIMER = 0.0
		elif collider.name.contains("Bullet"):
			damage(50)
			collider.queue_free()
		elif collider.name.contains("pool"):
			if HIT_TIMER > HIT_COOLDOWN:
				print("hit acid")
				velocity.y += 10
				damage(25)
				HIT_TIMER = 0.0
	
	# Player movement and jump logic
	if Input.is_action_just_pressed("ui_accept"):
		if !doing_action and !roulette_active and is_on_floor():
			doing_action = true
			if !roulette_instance:
				var roulette_scene = load("res://scenes/ruletti.tscn") as PackedScene
				if roulette_scene:
					roulette_instance = roulette_scene.instantiate()
					var camera_node = get_tree().root.get_node("Game/Pleijeri/Camera3D")
					if camera_node:
						camera_node.add_child(roulette_instance)
						for i in items:
							roulette_instance.get_node("rulettitausta/Sprite3D").add_option(i)
						roulette_instance.name = "Roulette"
			
			roulette_active = true
		elif roulette_active:
			roulette_active = false
			$suuntaNuoli.visible = true

	# Gravity handling
	if !is_on_floor():
		velocity += get_gravity() * delta
		velocity.y = max(velocity.y, -9.81)
	elif is_on_floor() and velocity.y == 0:
		velocity.x *= delta
		velocity.z *= delta
		

	# Apply movement
	move_and_slide()
	
# Apply knockback to enemy when the player hits it
func apply_knockback_to_enemy(enemy: Node3D) -> void:
	if enemy is CharacterBody3D:
		var knockback_direction = (enemy.global_transform.origin - global_transform.origin).normalized()
		enemy.velocity += knockback_direction * PUSH_FORCE  # Adjust knockback force for enemy
		if KB_USES > 0:
			KB_USES -= 1
			abText.text = "KB left: " + str(KB_USES)
			if KB_USES == 0:
				abText.text = ""
				PUSH_FORCE = 20
			print("Enemy knocked back by player!")

func roulette_action(action):
	if action == "jump":
		var angleRadian = rotation_degrees.y * (PI / 180.0)
		var direction := Vector3(0.0, 0.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), angleRadian)
		velocity.y = JUMP_HEIGHT
		velocity.x = direction.x * JUMP_DISTANCE
		velocity.z = direction.z * JUMP_DISTANCE
	elif action == "shoot":
		shoot_bullet()
		items.erase("shoot")
	elif action == "knockback":
		PUSH_FORCE = 40
		KB_USES = 5
		abText.text = "KB left: " + str(KB_USES)
		items.erase("knockback")
	elif action == "acid":
	# Save the player's current position before jumping
		var old_pos = global_position
	
	# Calculate jump direction and apply jump velocity
		var angleRadian = rotation_degrees.y * (PI / 180.0)
		var direction := Vector3(0.0, 0.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), angleRadian)
		velocity.y = JUMP_HEIGHT
		velocity.x = direction.x * JUMP_DISTANCE
		velocity.z = direction.z * JUMP_DISTANCE
	
	# Create an instance of the acid pool
		var instance = pool.instantiate()
	
	# Add the acid pool to the player's parent, not the player itself
		get_parent().add_child(instance)
	# Set the acid pool's position to the old position (where the player jumped from)
		HIT_TIMER = 0.0
		instance.global_position = old_pos
		
		items.erase("acid")


	$suuntaNuoli.visible = true
	doing_action = false

func damage(amount):
	hp -= amount
	hpText.text = "♡ "+str(hp)
func heal(amount):
	hp += amount
	hpText.text = "♡ "+str(hp)

func shoot_bullet():
	var bullet_scene = load("res://scenes/bullet.tscn") as PackedScene
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)  # Add the bullet to the same parent as the shooter

		# Set the bullet's position to the player's position, slightly in front
		bullet.position = position + transform.basis.z

		# Set the bullet's rotation to match the player's rotation
		bullet.rotation = rotation

		# Pass the player's forward direction to the bullet
		bullet.set_direction(transform.basis.z.normalized())
