extends StaticBody3D

# Cas 1: Perte des pétales si une abeille a butiné la fleur les pétales passent du jaune au vert et plus de pétales
@onready var petales = [$Petale1, $Petale2, $Petale3, $Petale4, $Petale5]

@onready var pistiles = [
	$Pistile, $Pistile2, $Pistile3, $Pistile4,
	$Pistile5, $Pistile6, $Pistile7, $Pistile8, 
	$Pistile9, $Pistile10, $Pistile11, $Pistile12
]

# Couleur du pistille (true = vert, false = jaune)
var pistile_doit_etre_vert = false

# Variables temps écoulé pendant la chute init à 0s
var temps_chute = 0.0
var timer = 0.0

# État des pétales (false = non supprimé , true = pétale supprimé)
var petales_supprimes = false
var indexTabPistile = 0

# Couleurs pistille
var couleur_jaune = Color(0.627, 0.737, 0.0)
var couleur_verte = Color(0.0, 0.325, 0.0)

# État général de la fleur (true = fanée)
var fanee: bool = false


func _ready():
	# Appliquer la couleur au démarrage selon le boolean
	$ZoneDetection.body_entered.connect(_detection_abeille)
	pistile_doit_etre_vert = false
	appliquer_couleur_pistiles()
	add_to_group("fleurs")


func _process(delta):
	if fanee:
		return  # Si la fleur est déjà fanée, on arrête tout

	timer += delta
	# Cas 1: Perte des pétales si une abeille a butiné la fleur les pétales passent du jaune au vert et plus de pétales
	
	# Vérifier si les pistiles sont verts
	if pistile_doit_etre_vert and not petales_supprimes:
		# Faire tomber et supprimer les pétales
		temps_chute += 0.001
		
		# Animation de chute de pétale
		for petale in petales:
			if petale and is_instance_valid(petale):
				petale.position.y -= 0.5 * 0.01
				petale.rotation.z += randf_range(-1, 1) * 0.01
		
		# Supprimer après 5 secondes
		if temps_chute >= 0.15:
			supprimer_petales()
			
	# Cas 2 : si aucune abeille n'est venue polliniser la fleur au bout de 30 secondes alors perte des pétales 
	elif not pistile_doit_etre_vert and timer > 20.0 and not petales_supprimes:
		# Faire tomber et supprimer les pétales
		temps_chute += 0.001
		
		# Animation de chute de pétale
		for petale in petales:
			if petale and is_instance_valid(petale):
				petale.position.y -= 0.5 * 0.01
				petale.rotation.z += randf_range(-1, 1) * 0.01
		
		# Supprimer après 5 secondes
		if temps_chute >= 0.15:
			supprimer_petales()
			

func appliquer_couleur_pistiles():
	# Choisir la couleur selon le boolean
	var couleur = couleur_verte if pistile_doit_etre_vert else couleur_jaune
	
	# Appliquer à tous les pistiles la couleur 
	for pistile in pistiles:
		if pistile:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = couleur
			pistile.set_surface_override_material(0, mat)


# Cas 1 deuxième Proposition : pour que les pétales tombent, chaque abeille posée sur la fleur fait changer de couleur du jaune au vert que quelques pistiles
# Si contact avec abeille 
# alors appeler la méthode appliquer_couleur_pistiles v2 
# si 3 contacts d'abeille alors perte des pétales 
		
		
# Version 1 : Condition pour changement de couleur 
# Si contact body_entered avec abeille sur fleur
# Alors pistile_doit_etre_vert = true
# get_tree().get_nodes_in_group("abeilles")

func _detection_abeille(body):
	if fanee:
		return  # Si la fleur est déjà fanée, on ignore
	if body.is_in_group("abeilles"):
		pistile_doit_etre_vert = true 
		appliquer_couleur_pistiles()


# Version 2 changement couleur : change couleur 4 pistilles
# func appliquer_couleur_pistiles():
# 	var couleur = couleur_verte if pistile_doit_etre_vert else couleur_jaune
# 	var numpistil = min(indexTabPistile +4, pistiles.size())
# 	for i in range(indexTabPistile,numpistil):
# 		var pistile=pistiles[i]
# 		if pistile:
# 			var mat = StandardMaterial3D.new()
# 			mat.albedo_color = couleur
# 			pistile.set_surface_override_material(0, mat)
# 	indexTabPistile = numpistil
# 	if indexTabPistile >= pistiles.size():
# 		pistile_doit_etre_vert = true
#
# Version 2: 	
# func _detection_abeille(body):
# 	if body.is_in_group("abeilles"):
# 		pistile_doit_etre_vert = true 
# 		appliquer_couleur_pistiles()
		

# --- Suppression des pétales + désactivation de la fleur ---
func supprimer_petales():
	print("Pétales supprimés!")
	for petale in petales:
		if petale and is_instance_valid(petale):
			petale.queue_free()
	petales_supprimes = true
	fanee = true

	# Empêcher toute nouvelle détection
	if $ZoneDetection:
		$ZoneDetection.monitoring = false
		$ZoneDetection.monitorable = false

	# Retirer du groupe "fleurs"
	if is_in_group("fleurs"):
		remove_from_group("fleurs")


# --- Permet à l'abeille de savoir si la fleur est fanée ---
func is_fanee() -> bool:
	return fanee
