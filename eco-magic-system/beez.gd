extends RigidBody3D

@export var speed: float = 4.0
var target: Node3D = null
var possible_targets: Array[Node] = []


func _ready():
	add_to_group("abeilles")


func _process(_delta: float) -> void:
	# Met à jour la liste des fleurs actives
	possible_targets = get_tree().get_nodes_in_group("fleurs")

	# Si aucune cible, en choisir une nouvelle
	if target == null:
		change_target()

	# Petits mouvements aléatoires pour la vie
	var fz = 5 * randf()
	apply_central_force(Vector3(fz, 0.1, fz))

	# Réinitialisation si dépasse les limites
	if position.z > 25 or position.z < -25:
		position.x = 0
		position.y = 0.1


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if target and (not is_instance_valid(target) or (target.has_method("is_fanee") and target.is_fanee())):
		print("Cible fanée ou supprimée, changement de cible.")
		change_target()
		return

	if not target:
		return

	var my_pos: Vector3 = state.transform.origin
	var target_pos: Vector3 = target.global_transform.origin
	var to_target: Vector3 = target_pos - my_pos
	var distance: float = to_target.length()
	look_at(target_pos)

	# Empêcher plusieurs abeilles sur la même fleur
	var other_bees = get_tree().get_nodes_in_group("abeilles")
	for bee in other_bees:
		if bee != self and bee.target == target:
			bee.change_target()

	# Si proche de la fleur → pause + nouvelle cible
	if to_target.length() < 0.5:
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		change_target()
		return

	# Direction vers la cible
	var direction: Vector3 = to_target / distance
	state.linear_velocity = direction.normalized() * speed


func change_target():
	# Met à jour la liste de fleurs actives
	possible_targets = get_tree().get_nodes_in_group("fleurs")

	# Filtrer uniquement celles qui ne sont pas fanées
	var fleurs_valides: Array[Node] = []
	for f in possible_targets:
		if f.has_method("is_fanee") and not f.is_fanee():
			fleurs_valides.append(f)

	if fleurs_valides.size() > 0:
		target = fleurs_valides.pick_random()
	else:
		target = null
		print("Aucune fleur valide disponible.")
