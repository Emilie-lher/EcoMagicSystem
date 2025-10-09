extends RigidBody3D

# Target can be a Node3D (assign in inspector) or a NodePath
var target: Node3D
@export var speed: float = 4.0           # vitesse  (m/s)
var possible_targets: Array[Node]

#Called every time
func _process(_delta: float) -> void:
	add_to_group("abeilles")
	possible_targets = get_tree().get_nodes_in_group("fleurs")
	# On assigne une target aléatoirement
	if target == null:
		change_target()
	var fz = 5*(randf())
	#Stabilise l'abeille
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
	print(target)
	if target:
		target_pos = target.global_transform.origin
	else:
		print("target non assigné")
	var to_target: Vector3 = target_pos - my_pos
	# Donne la longueur du vecteur entre la position de l'abeille et la position de la target
	var distance: float = to_target.length()
	look_at(target_pos)

	#Vérifie que seule cette abeille aie pour cible cette fleur.
	var other_bees = get_tree().get_nodes_in_group("abeilles")
	for bee in other_bees:
		if bee != self and bee.target == target:
			# Une autre abeille a déjà cette cible, on change la cible de l'autre abeille
			bee.change_target()

	#Ralentissement de l'abeille
	if to_target.z <0.04 && to_target.x < 0.04:
		# On est proche de la target
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		axis_lock_angular_y = true
		axis_lock_angular_x = true
		change_target()
	
	# direction vers la cible
	var direction: Vector3 = to_target / distance
	var desired_velocity: Vector3 = direction
	# desired_velocity.normalized() = la direction pour aller vers la target, avec une longueur de 1.
	# on la multiplie par un float 
	state.linear_velocity = desired_velocity.normalized() * speed
	
func change_target():
	if possible_targets.size() > 0:
		target = possible_targets.pick_random()
	else:
		print("possible_targets vide")
