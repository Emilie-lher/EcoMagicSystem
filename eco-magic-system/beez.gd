extends RigidBody3D

# Target can be a Node3D (assign in inspector) or a NodePath
@export var target: Node3D	#Contient la target séléectionné dans la scène
@export var speed: float = 7.0            # vitesse  (m/s)

#Called every time
func _process(delta: float) -> void:
	var fz = 5*(randf())
	apply_central_force(Vector3(fz,0.1,fz))
	
	if position.z > 25:
		position.x = 0
		position.y = 0.1
	if  position.z < -25:
		position.x = 0
		position.y = 0.1
		
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	var my_pos: Vector3 = state.transform.origin
	var target_pos: Vector3
	#Si l'abeille a bien une cible
	if target:
		target_pos = target.global_transform.origin
	else:
		print("target non assigné")
	var to_target: Vector3 = target_pos - my_pos
	# Donne la longueur du vecteur entre la position de l'abeille et la position de la target
	var distance: float = to_target.length()
	look_at(target_pos)

	#Ralentissement de l'abeille
	if to_target.z < 0.5 && to_target.x < 0.5:
		# On est proche de la target
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO  
		axis_lock_angular_y = true
		axis_lock_angular_x = true
		return
	
	# direction vers la cible
	var direction: Vector3 = to_target / distance
	var desired_velocity: Vector3 = direction
	# desired_velocity.normalized() = la direction pour aller vers la target, avec une longueur de 1.
	# on la multiplie par un float 
	state.linear_velocity = desired_velocity.normalized() * speed
	
	
