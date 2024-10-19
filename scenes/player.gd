extends CharacterBody3D

const JUMP_DISTANCE = 2.0
const JUMP_HEIGHT = 4.5
const SPIN = 3.0

var doing_action = false
var roulette_active = false
var roulette_instance = null
var items: Array[String] = []
# Movement speed on the ground
var speed: float = 5.0  # You can adjust this value
var HIT_TIMER: float = 0.0
const HIT_COOLDOWN: float = 0.5

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
		elif collider.name == "enemy":  # Assuming enemy's name is "enemy"
			if HIT_TIMER > HIT_COOLDOWN:
				apply_knockback_to_enemy(collider)
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
	elif is_on_floor() and !doing_action and velocity.y == 0:
		# Horizontal movement logic (apply speed when on the floor)
		var input_direction = Vector3.ZERO
		if Input.is_action_pressed("ui_left"):
			input_direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			input_direction.x += 1
		if Input.is_action_pressed("ui_up"):
			input_direction.z -= 1
		if Input.is_action_pressed("ui_down"):
			input_direction.z += 1

		if input_direction != Vector3.ZERO:
			input_direction = input_direction.normalized()
			velocity.x = input_direction.x * speed
			velocity.z = input_direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	# Apply movement
	move_and_slide()
	
# Apply knockback to enemy when the player hits it
func apply_knockback_to_enemy(enemy: Node3D) -> void:
	if enemy is CharacterBody3D:
		var knockback_direction = (enemy.global_transform.origin - global_transform.origin).normalized()
		enemy.velocity += knockback_direction * 10.0  # Adjust knockback force for enemy
		print("Enemy knocked back by player!")

func roulette_action(action):
	if action == "jump":
		var angleRadian = rotation_degrees.y * (PI / 180.0)
		var direction := Vector3(0.0, 0.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), angleRadian)
		velocity.y = JUMP_HEIGHT
		velocity.x = direction.x * JUMP_DISTANCE
		velocity.z = direction.z * JUMP_DISTANCE

	$suuntaNuoli.visible = true
	doing_action = false
