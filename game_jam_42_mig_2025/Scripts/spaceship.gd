extends Node2D

const ORBIT_RADIUS_X: float = 250.0  # Radio en el eje X (semi-eje mayor)
const ORBIT_RADIUS_Y: float = 80.0   # Radio en el eje Y (semi-eje menor)
const ORBIT_SPEED: float = 1.0       # Velocidad fija de la órbita
const NUM_FRAMES: int = 72            # Número de frames de la nave

var angle: float = 0.0    # Ángulo de la órbita
var offset_angle: float = 0.0  # Ángulo inicial único para cada nave

var spaceship_sprite: Sprite2D  # Nodo de la nave (Sprite2D)
var spaceship_textures: Array = []  # Lista para almacenar las texturas de la nave

func _ready():
	add_to_group("spaceships")  # Añadir la nave al grupo
	
	# Ángulo inicial aleatorio para cada nave
	offset_angle = randf() * 2 * PI  # Ángulo inicial aleatorio
	spaceship_sprite = $Sprite2D  # Nodo Sprite2D de la nave
	
	# Cargar las texturas de la nave en la lista
	for i in range(NUM_FRAMES):
		var texture = load("res://Sprites/space_ships/human_ship/frame_" + str(i) + ".png")  # Asumiendo que los archivos se llaman ship_0.png, ship_1.png, ...
		spaceship_textures.append(texture)  # Añadir la textura a la lista

func _process(delta):
	var parent_node = get_parent()  # Obtener el nodo padre de la nave

	if parent_node:
		# Actualizar el ángulo según la velocidad de la órbita
		angle += ORBIT_SPEED * delta  # Actualizar el ángulo según la velocidad

		# Nueva posición en la órbita elíptica alrededor del nodo padre
		# Utilizamos el espacio relativo a su padre
		position = Vector2(
			ORBIT_RADIUS_X * cos(angle + offset_angle),  
			ORBIT_RADIUS_Y * sin(angle + offset_angle)
		)

		# Cambiar la textura dependiendo del ángulo
		var frame_index = int((angle + offset_angle) / (2 * PI) * NUM_FRAMES) % NUM_FRAMES
		spaceship_sprite.texture = spaceship_textures[frame_index]  # Asignar la textura correspondiente

		# Ajustar el z_index para simular profundidad (ocultar cuando pasa detrás del nodo padre)
		if sin(angle + offset_angle) < 0:
			z_index = parent_node.z_index - 1  # Detrás del nodo padre
		else:
			z_index = parent_node.z_index + 1  # Delante del nodo padre
	else:
		print("⚠️ No se encontró el nodo padre.")
