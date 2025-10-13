extends RigidBody3D

@export var speed: float = 6.0
@export var ruche: Node3D

var target: Node3D = null
var possible_targets: Array = []
var fleurs_visitees: Array = []
var nombre_butins: int = 0
var en_pause: bool = false
var en_pause_sur_fleur: bool = false

@export var temps_max_sans_fleur: float = 18.0  # en secondes
var temps_depuis_derniere_fleur: float = 0.0



func _ready():
	add_to_group("abeilles")
	# Commencer juste au-dessus de la ruche si elle est assignée
	if ruche:
		global_position = ruche.global_position + Vector3(0, 1.5, 0)
		
		
	# Connecter la détection de collision
	var area = $Area3D
	if area:
		area.body_entered.connect(_on_body_entered)
	
	change_target()


func _process(_delta: float) -> void:
	possible_targets = get_tree().get_nodes_in_group("fleurs")
	if not en_pause and not en_pause_sur_fleur:
		temps_depuis_derniere_fleur += _delta

		if temps_depuis_derniere_fleur >= temps_max_sans_fleur:
			_mourir()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if en_pause:
		state.linear_velocity = Vector3.ZERO
		return

	if not target:
		change_target()
		return

	var my_pos: Vector3 = state.transform.origin
	var target_pos: Vector3 = target.global_transform.origin
	var to_target: Vector3 = target_pos - my_pos
	var distance: float = to_target.length()

	look_at(target_pos)

	# Si proche de la cible
	if distance < 0.5:
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO

		# Si c’est la ruche
		if target == ruche:
			_rester_dans_ruche()
		else:
			# Si c’est une fleur
			if not en_pause_sur_fleur:
				await _butiner_fleur(target)
		return

	# --- Évitement entre abeilles ---
	var other_bees = get_tree().get_nodes_in_group("abeilles")
	var avoidance_force = Vector3.ZERO

	for bee in other_bees:
		if bee != self and bee.is_inside_tree():
			var to_other = global_position - bee.global_position
			var distances = to_other.length()
			if distance < 2.0: # distance d'évitement
				avoidance_force += to_other.normalized() / distances

	# On combine cette force d’évitement à la direction principale
	var direction: Vector3 = (to_target.normalized() + avoidance_force * 0.5).normalized()
	state.linear_velocity = direction * speed
	

func ajouter_fleur_visitee(fleur: Node3D):
	if fleur not in fleurs_visitees:
		fleurs_visitees.append(fleur)
		nombre_butins += 1
		temps_depuis_derniere_fleur = 0.0
		print("Abeille a butiné une fleur. Total :", nombre_butins)

	# Après 2 fleurs → retour à la ruche
	if nombre_butins >= 2:
		retourner_a_la_ruche()
	else:
		change_target()


func retourner_a_la_ruche():
	print("Abeille retourne à la ruche avec nombre de butin =", nombre_butins)
	target = ruche


func _rester_dans_ruche() -> void:
	if en_pause:
		return
	en_pause = true
	print("Abeille se repose dans la ruche")

	await get_tree().create_timer(3.0).timeout

	print("Abeille repart butiner")
	fleurs_visitees.clear()
	nombre_butins = 0
	en_pause = false
	change_target()


func change_target():
	if en_pause:
		return

	# Liste des fleurs non encore visitées
	var fleurs_disponibles: Array = []
	for f in possible_targets:
		if f != null and f.is_inside_tree() and f not in fleurs_visitees:
			fleurs_disponibles.append(f)

	if fleurs_disponibles.size() > 0:
		target = fleurs_disponibles.pick_random()
	else:
		print("Aucune fleur disponible, retour à la ruche")
		target = ruche

func _butiner_fleur(fleur: Node3D) -> void:
	en_pause_sur_fleur = true
	print("Butinage de la fleur...")

	# Attendre 1 à 2 secondes aléatoirement
	var duree = randf_range(1.0, 2.0)
	await get_tree().create_timer(duree).timeout

	# Ajouter la fleur visitée après le butinage
	ajouter_fleur_visitee(fleur)

	en_pause_sur_fleur = false
	
func _mourir():
	print("Abeille est morte faute de fleurs !")
	queue_free()  # supprime l'abeille de la scène
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("abeilles"):
		# On récupère la position actuelle
		var pos = global_transform.origin
		pos.x += 0.05
		
		# On applique la nouvelle position
		global_transform.origin = pos
		
		# On stoppe la vitesse pour éviter que l'abeille courante soit propulsée
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		if(nombre_butins >= 2):
			retourner_a_la_ruche()
		else:
			change_target()
