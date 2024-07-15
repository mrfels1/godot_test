extends Marker3D

@onready var player = get_node("..")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta):
	if (player != null) and player.direction != Vector3.ZERO:
		var direction = Vector3.ZERO
		direction = player.direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)
