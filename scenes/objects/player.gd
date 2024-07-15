extends CharacterBody3D

@export var acceleration = 200
@export var deceleration = 200
@export var fall_acceleration = 150
@export var max_speed = 20
@export var jump_impulse = 250
@export var bounce_impulse = 300


var speed_vector = Vector3.ZERO
var acceleration_vector: Vector3 = Vector3.ZERO

func _physics_process(delta):
	acceleration_vector = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		acceleration_vector.x += 1
	if Input.is_action_pressed("move_left"):
		acceleration_vector.x -= 1
	if Input.is_action_pressed("move_backward"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		acceleration_vector.z += 1
	if Input.is_action_pressed("move_forward"):
		acceleration_vector.z -= 1

	if acceleration_vector != Vector3.ZERO:
		acceleration_vector = acceleration_vector.normalized()
		acceleration_vector *= acceleration 
		
	elif(is_on_floor()):
		var speed_v2 = Vector2(speed_vector.z,speed_vector.x)
		if(speed_v2.length() > (deceleration * delta)):
			speed_vector.z -= speed_vector.normalized().z * deceleration * delta
			speed_vector.x -= speed_vector.normalized().x * deceleration * delta			
		else:
			speed_vector = Vector3.ZERO
	
	speed_vector += acceleration_vector * delta 
	speed_vector = speed_vector.limit_length(max_speed)
	# Vertical Velocity
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		speed_vector.y = jump_impulse
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		speed_vector.y -= fall_acceleration * delta #Стремится к бесконечности
	
	# Iterate through all collisions that occurred this frame
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)

		# If the collision is with ground
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				speed_vector.y  = bounce_impulse
				# Prevent further duplicate calls.
				break
	# Moving the Character
	if(!speed_vector.is_zero_approx() and (speed_vector.cross(Vector3(0,1,0)) != Vector3(0,0,0))):
			$Pivot.basis = Basis.looking_at(speed_vector,Vector3(0,1,0))
	velocity = speed_vector
	move_and_slide()
		
