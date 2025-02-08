extends Node2D
# Constantes para la órbita
const ORBIT_RADIUS_X: float = 250.0  # Radio en el eje X (semi-eje mayor)
const ORBIT_RADIUS_Y: float = 80.0   # Radio en el eje Y (semi-eje menor)
const ORBIT_SPEED: float = 1.0       # Velocidad fija de la órbita
const NUM_FRAMES: int = 72           # Número de frames de la animación
var angle: float = 0.0      # Ángulo acumulado de la órbita
var offset_angle: float = 0.0  # Desfase aleatorio inicial
var target_planet: Node = null  # Planeta destino para reanexar la nave
var spaceship_sprite: Sprite2D       # Nodo Sprite2D de la nave
var spaceship_textures: Array = []   # Texturas para la animación
@export var faction: int             # 1 para humanos, 2 para enemigos
# --- NUEVAS VARIABLES PARA EL VIAJE ---
var is_traveling: bool = false      # Indica si la nave está en modo viaje
var destination: Vector2            # Coordenada global destino
@export var travel_speed: float = 200.0  # Velocidad de viaje (en píxeles por segundo)
func _ready():
	add_to_group("spaceships")
	offset_angle = randf() * 2 * PI
	spaceship_sprite = $Sprite2D
	for i in range(NUM_FRAMES):
		var texture_path = ""
		if faction == 1:
			texture_path = "res://Sprites/space_ships/human_ship/frame_" + str(i) + ".png"
		elif faction == 2:
			texture_path = "res://Sprites/space_ships/enemy_ship/frame_" + str(i) + ".png"
		spaceship_textures.append(load(texture_path))
func _process(delta):
	if is_traveling:
		# Moverse linealmente hacia el destino
		var current_pos = global_position
		var direction = (destination - current_pos).normalized()
		# Calcula la distancia que se moverá en este frame
		var step = travel_speed * delta
		if global_position.distance_to(destination) <= step:
			global_position = destination
			is_traveling = false
			# Reanexar la nave al planeta destino usando la variable target_planet
			if target_planet:
				var current_global = global_position
				get_parent().remove_child(self)
				target_planet.add_child(self)
				position = target_planet.to_local(current_global)
				# Reinicia la órbita, si es necesario
				angle = 0.0
				offset_angle = randf() * 2 * PI
				target_planet = null  # Limpiar la referencia tras reanexar
		else:
			global_position += direction * step
		# Actualiza la animación (si lo deseas) usando el ángulo acumulado o incluso
		# podrías pausar la animación de órbita durante el viaje.
		var frame_index = int((angle + offset_angle) / (2 * PI) * NUM_FRAMES) % NUM_FRAMES
		spaceship_sprite.texture = spaceship_textures[frame_index]
	else:
		# Modo órbita: se asume que la nave es hija del planeta en el que orbita
		angle += ORBIT_SPEED * delta
		position = Vector2(
			ORBIT_RADIUS_X * cos(angle + offset_angle),
			ORBIT_RADIUS_Y * sin(angle + offset_angle)
		)
		var frame_index = int((angle + offset_angle) / (2 * PI) * NUM_FRAMES) % NUM_FRAMES
		spaceship_sprite.texture = spaceship_textures[frame_index]
		# Se ajusta el z_index según el seno (para simular profundidad)
		z_index = get_parent().z_index + (1 if sin(angle + offset_angle) >= 0 else -1)
# Función para iniciar el viaje hacia una posición destino
func travel_to(dest: Vector2, new_planet: Node = null) -> void:
	destination = dest
	target_planet = new_planet
	is_traveling = true
	# Desanexa la nave del planeta actual (suponiendo que GlobalShips es un nodo para naves en tránsito)
	var global_container = get_tree().get_root().get_node("GlobalShips")
	if global_container:
		get_parent().remove_child(self)
		global_container.add_child(self)
