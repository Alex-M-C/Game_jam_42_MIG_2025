extends Node2D
var line : Line2D
@export var planets : Array [Node2D] = []
var start_position : Vector2
var end_position : Vector2
var is_drawing : bool = false
var valid_area : Area2D = null  # Última área seleccionada
var is_over_area : bool = false  # Indica si el ratón está sobre un área válida
func _ready():
	# Crear la línea que será usada para dibujar
	line = Line2D.new()
	add_child(line)
	line.default_color = Color(0.678, 0.847, 0.901, 0.75)
	line.width = 6
	
	var areas: Array[Area2D] = []
	for node in planets:
		var area : Area2D = node.get_node("Area2D")  # Busca el Area2D dentro de cada nodo
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
		if not is_drawing:
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
			# Por ejemplo, obtenemos todas las naves del planeta de origen
			for ship in get_tree().get_nodes_in_group("spaceships"):
				# Si la nave pertenece al planeta origen, iniciar el viaje
				# Aquí debes determinar si la nave debe viajar y posiblemente reparentarla
				ship.travel_to(area_center)
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
