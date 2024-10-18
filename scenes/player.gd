extends CharacterBody3D


const JUMP_DISTANCE = 5.0
const JUMP_HEIGHT = 4.5
const SPIN = 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_on_floor():
		rotate_y(SPIN * delta)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_HEIGHT

	var angleRadian = rotation_degrees.y * (PI / 180.0)
	var direction := Vector3(0.0, 0.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), angleRadian)

	if not is_on_floor():
		$suuntaNuoli.visible = false
		velocity += get_gravity() * delta
		velocity.x = direction.x * JUMP_DISTANCE
		velocity.z = direction.z * JUMP_DISTANCE
	else:
		$suuntaNuoli.visible = true
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
