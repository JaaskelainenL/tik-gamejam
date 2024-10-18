extends Sprite3D

var spinning: bool = true # Variable to track whether the sprite is spinning
# Reference to the Label node
@onready var label_node: Label3D = get_parent().get_node("Label3D") # Adjust the path to match the actual location of your Label node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spinning:
		# Rotate the Sprite3D around the Y-axis
		rotate_z(5*delta)

# Handle input to toggle spinning and update the label when the space bar is pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"): # Default action for space bar in Godot
		spinning = !spinning # Toggle the spinning state
		
		# Update the label to show the current rotation axis
		label_node.text = str(wrapf(rotation_degrees.z, 0, 360))
