extends Node3D

@onready var bee_scene: PackedScene = preload("res://beez.tscn")
@onready var flower_scene: PackedScene = preload("res://flower.tscn")

@export var bee_count: int = 1
@export var start_flower_count: int = 4
@export var respawn_delay: float = 1.0

@export var terrain_min: Vector3 = Vector3(-10, 0, -10)
@export var terrain_max: Vector3 = Vector3(10, 0, 10)

var tracked_flowers: Array = []

func _ready():
	_spawn_bees()
	_spawn_initial_flowers()

	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_monitor_flowers)
	add_child(timer)


# --------------------------
#  Création des abeilles
# --------------------------
func _spawn_bees():
	for i in range(bee_count):
		var bee = bee_scene.instantiate()
		add_child(bee)
		bee.global_transform.origin = _random_position()


# --------------------------
#  Créations des fleurs au lancement de la scène
# --------------------------
func _spawn_initial_flowers():
	for i in range(start_flower_count):
		_spawn_flower()


# --------------------------
#  Création d'une fleur une fois qu'une fleur est butinée
# --------------------------
func _spawn_flower():
	var flower = flower_scene.instantiate()
	add_child(flower)
	flower.global_transform.origin = _random_position()
	tracked_flowers.append(flower)
	
func _delayed_flower_spawn() -> void:
	await get_tree().create_timer(respawn_delay).timeout
	_spawn_flower()


# --------------------------
#  Surveillance des fleurs
# --------------------------
func _monitor_flowers():
	for flower in tracked_flowers:
		if flower and flower.is_fanee():
			# On remplace uniquement cette fleur
			tracked_flowers.erase(flower)
			if is_instance_valid(flower):
				flower.queue_free()
			_delayed_flower_spawn()
			break  # On en traite une à la fois


# --------------------------
#  Instanciation des éléments dans le terrain
# --------------------------
func _random_position() -> Vector3:
	return Vector3(
		randf_range(terrain_min.x, terrain_max.x),
		terrain_min.y,
		randf_range(terrain_min.z, terrain_max.z)
	)
