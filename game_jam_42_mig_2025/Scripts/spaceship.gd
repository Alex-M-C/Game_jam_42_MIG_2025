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
		# Mover la nave en la dirección del destino
		var current_pos = global_position
		var direction = (destination - current_pos).normalized()
		var step = travel_speed * delta
		# Si está cerca del destino, detenerse
		if global_position.distance_to(destination) <= step:
			global_position = destination
			is_traveling = false
			if target_planet:
				var current_global = global_position
				get_parent().remove_child(self)
				target_planet.add_child(self)
				position = target_planet.to_local(current_global)
				angle = 0.0
				offset_angle = randf() * 2 * PI
				target_planet = null
		else:
			global_position += direction * step
		# --- SELECCIONAR EL SPRITE CORRECTO ---
		var angle_degrees = rad_to_deg(atan2(-direction.y, direction.x))  # Invertimos Y porque en Godot el eje Y crece hacia abajo
		if angle_degrees < 0:
			angle_degrees += 360  # Convertimos valores negativos a positivos
		# **Lista extendida de ángulos y sus sprites correctos**
		var angles = [0, 22.5, 45, 67.5, 90, 112.5, 135, 157.5, 180, 202.5, 225, 247.5, 270, 292.5, 315, 337.5]
		var sprites = [51, 46, 40, 37, 33, 30, 28, 24, 15, 11, 7, 4, 71, 67, 60, 56]
		# Encontramos el ángulo más cercano
		var closest_index = 0
		var min_diff = 360
		for i in range(angles.size()):
			var diff = abs(angle_degrees - angles[i])
			if diff < min_diff:
				min_diff = diff
				closest_index = i
		# Asignar el sprite correcto según la dirección
		spaceship_sprite.texture = spaceship_textures[sprites[closest_index]]
	else:
		# --- ORBITA NORMAL ---
		angle += ORBIT_SPEED * delta
		position = Vector2(
			ORBIT_RADIUS_X * cos(angle + offset_angle),
			ORBIT_RADIUS_Y * sin(angle + offset_angle)
		)
		var frame_index = int((angle + offset_angle) / (2 * PI) * NUM_FRAMES) % NUM_FRAMES
		spaceship_sprite.texture = spaceship_textures[frame_index]
		# Ajuste de profundidad
		z_index = get_parent().z_index + (1 if sin(angle + offset_angle) >= 0 else -1)
# Función para iniciar el viaje hacia una posición destino
func travel_to(dest: Vector2, new_planet: Node = null) -> void:
	destination = dest
	target_planet = new_planet  # Guardamos el planeta destino
	is_traveling = true
	# Desanexa la nave del planeta actual y la mueve al grupo de tránsito
	var global_container = get_tree().get_root().get_node("GlobalShips")
	if global_container:
		if get_parent() != null:
			get_parent().remove_child(self)
		else:
			print("El nodo no tiene un padre.")
		global_container.add_child(self)
