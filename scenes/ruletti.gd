extends Sprite3D

var spinning: bool = true # Variable to track whether the sprite is spinning
var options: Array[String] = ["jump"] # Initialize with default options
var labels: Array[Label3D] = [] # Array to hold the label nodes for each option
var num_options: int = 0 # Number of options currently available

# Reference to the parent Sprite3D and the Label3D node
@onready var player = get_tree().root.get_node("Game/Pleijeri")
@onready var parent_node: Sprite3D = get_parent() as Sprite3D
@onready var label_node: Label3D = get_parent().get_node("Label3D") # This can be a template label for creating new labels

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Initialize the wheel with existing options
	update_options()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spinning:
		rotate_z(5 * delta)

# Handle input to toggle spinning and update the label when the space bar is pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		spinning = !spinning # Toggle the spinning state
		if not spinning:
			# If the wheel has stopped spinning, determine the current option
			var wrapped_rotation = wrapf(rotation_degrees.z, 0, 360)
			var selected_option = get_selected_option(wrapped_rotation)
			print("Stopped on: " + selected_option)
			player.roulette_action(selected_option)
			parent_node.get_parent().queue_free()

# Function to get the selected option based on the rotation angle
func get_selected_option(rotation_degrees: float) -> String:
	if num_options == 0:
		return "No options available"

	var angle_step = 360.0 / num_options
	var selected_index = int((rotation_degrees - 90 + (angle_step/2)) / angle_step) % num_options
	return options[selected_index]

# Function to add a new option
func add_option(action_name: String) -> void:
	if action_name not in options: # Avoid adding duplicates
		options.append(action_name)
		update_options()

# Function to remove an option
func remove_option(action_name: String) -> void:
	if action_name in options:
		options.erase(action_name)
		update_options()

func update_options() -> void:
	# Clear previous labels and lines
	for label in labels:
		label.queue_free()
	labels.clear()
	
	num_options = options.size()
	
	if num_options == 0:
		return
	
	# If there's only one option, don't draw any lines
	if num_options == 1:
		# Create a label for the single option without drawing any lines
		create_label_for_option(0, 0.0)
		return
	
	# Draw lines for each segment and add labels
	var angle_step = 360.0 / num_options
	for i in range(num_options):
		var angle = deg_to_rad(i * angle_step+90)
		draw_line_on_parent(angle)
		create_label_for_option(i, (i + 0.5) * angle_step + 90) # Place label at the midpoint of the segment

# Draw a line on the parent node for the given angle
func draw_line_on_parent(angle: float) -> void:
	var line_length: float = 2.0 # Length of the line
	var start_point = Vector3(0, 0, 0)
	var end_point = Vector3(line_length, 0, 0)
	
	# Create a MeshInstance3D with an ImmediateMesh for drawing the line
	var mesh_instance = MeshInstance3D.new()
	var mesh = ImmediateMesh.new()
	
	# Begin the mesh surface
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# Set the color for the line
	var color = Color(1, 0, 0) # Red color
	mesh.surface_set_color(color)
	
	# Add the vertices for the line
	mesh.surface_add_vertex(start_point)
	mesh.surface_add_vertex(end_point)
	mesh.surface_end()
	
	# Assign the mesh to the mesh instance
	mesh_instance.mesh = mesh
	mesh_instance.position.z = 0.1
	mesh_instance.rotation.z = angle
	
	# Optionally, set a material to ensure the color is applied correctly
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	
	# Add the mesh instance to the parent node
	if parent_node:
		parent_node.add_child.call_deferred(mesh_instance)

func create_label_for_option(index: int, angle_degrees: float) -> void:
	# Check if label_node is not null
	if !label_node:
		print("Label3D node is not available. Cannot duplicate.")
		return
	
	var new_label = label_node.duplicate() as Label3D
	new_label.text = options[index]
	var angle = deg_to_rad(angle_degrees)
	
	# Calculate the radius based on the label's angle to make the positioning consistent
	var radius = 1.5
	
	# Calculate the position based on the angle and radius
	var label_position = Vector3(cos(angle) * radius - 0.55, sin(angle) * radius + 0.3, 1.0) # Set Z to a higher value to ensure it is in front
	new_label.transform.origin = label_position
	
	# Rotate the label to face outward from the center
	if angle > PI / 2 and angle < 3 * PI / 2: # Bottom half
		new_label.rotation = Vector3(0, 0, angle + PI)
	else: # Top half
		new_label.rotation = Vector3(0, 0, angle)
	
	# Set the label to be on the highest rendering layer and increase render priority
	new_label.render_priority = 10 # Higher value means it will render on top of objects with lower priority
	
	# Add the new label to the parent node
	parent_node.add_child.call_deferred(new_label)
	labels.append(new_label)
