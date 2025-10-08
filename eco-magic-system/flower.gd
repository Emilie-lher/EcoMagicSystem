extends RigidBody3D

@onready var petales = [$Petale1, $Petale2, $Petale3, $Petale4, $Petale5]

@onready var pistiles = [
	$Pistile, $Pistile2, $Pistile3, $Pistile4,
	$Pistile5, $Pistile6, $Pistile7, $Pistile8, 
	$Pistile9, $Pistile10, $Pistile11, $Pistile12
]

# Couleur du pistille (true = vert, false = jaune)
var pistile_doit_etre_vert = true

# Variables temps ecoulé pendant la chutte init a 0s
var temps_chute = 0.0
# Etat des pétale (false= non suprimé , true=pétale suprimé)
var petales_supprimes = false

# Couleurs pistille
var couleur_jaune = Color(0.627, 0.737, 0.0)
var couleur_verte = Color(0.0, 0.325, 0.0)

func _ready():
	# Appliquer la couleur au démarrage selon le boolean
	appliquer_couleur_pistiles()

func _process(delta):
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

func appliquer_couleur_pistiles():
	# Choisir la couleur selon le boolean
	var couleur = couleur_verte if pistile_doit_etre_vert else couleur_jaune
	
	# Appliquer à tous les pistiles la couleur 
	for pistile in pistiles:
		if pistile:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = couleur
			pistile.set_surface_override_material(0, mat)
	

func supprimer_petales():
	
	print("Pétales supprimés!")
	for petale in petales:
		if petale and is_instance_valid(petale):
			petale.queue_free()
	petales_supprimes = true
