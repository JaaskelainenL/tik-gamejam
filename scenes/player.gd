extends CharacterBody3D

const JUMP_DISTANCE = 2.0
const JUMP_HEIGHT = 4.5
const SPIN = 3.0

var doing_action = false
var roulette_active = false
var roulette_instance = null


func _process(delta: float) -> void:

	if is_on_floor() and !doing_action and !roulette_active:
		rotate_y(SPIN * delta)

func _physics_process(delta: float) -> void:
	#
	if Input.is_action_just_pressed("ui_accept"):
		if !doing_action and !roulette_active and is_on_floor():
			doing_action = true
			if !roulette_instance:
				var roulette_scene = load("res://scenes/ruletti.tscn") as PackedScene
				if roulette_scene:
					roulette_instance = roulette_scene.instantiate()
					# This is how you add extra options to the roulette
					#roulette_instance.get_node("rulettitausta/Sprite3D").add_option("test")

					var camera_node = get_tree().root.get_node("Game/Camera3D")
					if camera_node:
						camera_node.add_child(roulette_instance)
						roulette_instance.name = "Roulette"

			
			roulette_active = true
		elif roulette_active:
			roulette_active = false
			$suuntaNuoli.visible = true

	if !is_on_floor():
		velocity += get_gravity() * delta
	elif is_on_floor() and !doing_action and velocity.y == 0:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

func roulette_action(action):
	if action == "jump":
		var angleRadian = rotation_degrees.y * (PI / 180.0)
		var direction := Vector3(0.0, 0.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), angleRadian)
		velocity.y = JUMP_HEIGHT
		velocity.x = direction.x * JUMP_DISTANCE
		velocity.z = direction.z * JUMP_DISTANCE

	$suuntaNuoli.visible = true
	doing_action = false
