extends Node2D
@export var planets: Array[Node2D] = []
var start_position: Vector2
var end_position: Vector2
var is_drawing: bool = false
var valid_area: Area2D = null  # Última área seleccionada
var is_over_area: bool = false  # Indica si el ratón está sobre un área válida
var line: Line2D
func _ready():
	# Crear la línea que será usada para dibujar
	line = Line2D.new()
	add_child(line)
	line.default_color = Color(0.678, 0.847, 0.901, 0.75)
	line.width = 6
	var areas: Array[Area2D] = []
	for node in planets:
		var area: Area2D = node.get_node("Area2D")  # Busca el Area2D dentro de cada nodo
		if area:
			areas.append(area)
	for area in areas:
		area.connect("input_event", Callable(self, "_on_area_clicked").bind(area))
		area.connect("mouse_entered", Callable(self, "area_mouse_entered").bind(area))
		area.connect("mouse_exited", Callable(self, "area_mouse_exited").bind(area))
func _process(delta):
	if is_drawing:
		if not is_over_area:
			end_position = get_local_mouse_position()  # Si no está sobre un área, seguir al ratón
		line.clear_points()
		line.add_point(start_position)
		line.add_point(end_position)
func _on_area_clicked(viewport, event, shape_idx, area):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var area_center = area.global_position
		var planet = area.get_parent()
		if not is_drawing:
			if planet.planet_status == 1:
				start_position = to_local(area_center)
				valid_area = area
				is_drawing = true
		elif area != valid_area:
			end_position = to_local(area_center)
			# Dibujar la línea momentáneamente
			line.clear_points()
			line.add_point(start_position)
			line.add_point(end_position)
			await get_tree().create_timer(0.1).timeout
			line.clear_points()
			# Obtener el nodo del planeta de origen
			var origin_planet = valid_area.get_parent()
			# Enviar solo la mitad de las naves
			var ships_to_send = []
			for ship in origin_planet.get_children():
				if ship.is_in_group("spaceships") and ship.faction == 1:  # Solo enviar naves de la facción 1 (propias)
					ships_to_send.append(ship)
			var half_ships = ships_to_send.size() / 2
			for j in range(half_ships):
				var ship = ships_to_send[j]
				ship.travel_to(area_center, area.get_parent())  # Pasa la posición y el planeta de destino
			is_drawing = false
			valid_area = null
			is_over_area = false
# La línea se mueve automáticamente al centro del área cuando el mouse entra
func area_mouse_entered(area):
	if is_drawing and area != valid_area:
		end_position = to_local(area.global_position)
		is_over_area = true
# La línea vuelve a seguir el ratón si el mouse sale del área
func area_mouse_exited(area):
	if is_drawing and area != valid_area:
		is_over_area = false  # Permite que el ratón controle la línea nuevamente
# Si se hace clic en un área no válida, cancelar el dibujo
# Si se hace clic fuera de un área válida, se cancela el dibujo y desaparece la línea
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Si está dibujando pero el clic no fue en un área válida, se borra la línea
		if is_drawing and not is_over_area:
			is_drawing = false
			line.clear_points()
			valid_area = null
