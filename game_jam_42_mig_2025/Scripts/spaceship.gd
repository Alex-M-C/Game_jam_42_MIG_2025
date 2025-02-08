extends Node2D

const ORBIT_RADIUS_X: float = 250.0  # Radio en el eje X (semi-eje mayor)
const ORBIT_RADIUS_Y: float = 80.0   # Radio en el eje Y (semi-eje menor)
const ORBIT_SPEED: float = 1.0       # Velocidad fija de la órbita
const NUM_FRAMES: int = 72            # Número de frames de la nave

var angle: float = 0.0    # Ángulo de la órbita
var offset_angle: float = 0.0  # Ángulo inicial único para cada nave

var spaceship_sprite: Sprite2D  # Nodo de la nave (Sprite2D)
var spaceship_textures: Array = []  # Lista para almacenar las texturas de la nave

@export var faction: int  # 1 para humanos, 2 para enemigos

func _ready():
	add_to_group("spaceships")  # Añadir la nave al grupo
	
	offset_angle = randf() * 2 * PI  # Ángulo inicial aleatorio
	spaceship_sprite = $Sprite2D  # Nodo Sprite2D de la nave
	
	var parent_node = get_parent()
	
	for i in range(NUM_FRAMES):
		if faction == 1:
			var texture = load("res://Sprites/space_ships/human_ship/frame_" + str(i) + ".png")
			spaceship_textures.append(texture)
		elif faction == 2:
			var texture = load("res://Sprites/space_ships/enemy_ship/frame_" + str(i) + ".png")
			spaceship_textures.append(texture)

func _process(delta):
	var parent_node = get_parent()

	if parent_node:
		angle += ORBIT_SPEED * delta
		position = Vector2(
			ORBIT_RADIUS_X * cos(angle + offset_angle),  
			ORBIT_RADIUS_Y * sin(angle + offset_angle)
		)

		var frame_index = int((angle + offset_angle) / (2 * PI) * NUM_FRAMES) % NUM_FRAMES
		spaceship_sprite.texture = spaceship_textures[frame_index]

		z_index = parent_node.z_index + (1 if sin(angle + offset_angle) >= 0 else -1)
