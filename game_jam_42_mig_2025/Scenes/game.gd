extends Node2D

@export var arraylevel: Array[PackedScene] = []
var actualevel = 0

const VICTORY_PANEL = preload("res://Scenes/menus/victory_panel.tscn")
const DEFEAT_PANEL = preload("res://Scenes/menus/defeat_panel.tscn")
const FINAL_SCENE = preload("res://Scenes/levels/final_scene.tscn")

var current_instance: Node = null
var active_panel: Node = null  # Variable para guardar el panel activo

# Se ejecuta cuando el nodo entra en la escena por primera vez.
func _ready() -> void:
	_change_level(actualevel)

# Función para cambiar de nivel correctamente
func _change_level(level_index: int):
	# Eliminar el panel si existe
	if active_panel:
		active_panel.queue_free()
		active_panel = null
	
	# Eliminar la instancia del nivel actual
	if current_instance:
		current_instance.queue_free()

	# Cargar el nuevo nivel si existe
	if level_index < arraylevel.size():
		current_instance = arraylevel[level_index].instantiate()
		add_child(current_instance)
	else:
		print("No hay más niveles disponibles.")

# Se ejecuta en cada frame
func _process(delta: float) -> void:
	if not current_instance:
		return
	
	if actualevel < 5:
		var game_manager = current_instance.get_node("GameManager")
		
		if game_manager.game_over == 1:
			_show_victory_panel()
		elif game_manager.game_over == 2:
			_show_defeat_panel()
	

# Muestra el panel de victoria
func _show_victory_panel():
	if active_panel:  # Evitar que se dupliquen los paneles
		return

	active_panel = VICTORY_PANEL.instantiate()
	var next_button = active_panel.get_node("Button")
	if next_button:
		next_button.connect("pressed", Callable(self, "_on_victory_panel_closed"))
	get_tree().current_scene.add_child(active_panel)

# Muestra el panel de derrota
func _show_defeat_panel():
	if active_panel:  # Evitar que se dupliquen los paneles
		return

	active_panel = DEFEAT_PANEL.instantiate()
	var close_button = active_panel.get_node("Button")
	if close_button:
		close_button.connect("pressed", Callable(self, "_on_defeat_panel_closed"))
	get_tree().current_scene.add_child(active_panel)

# Función cuando el jugador pierde
func _on_defeat_panel_closed():
	_change_level(actualevel)  # Reiniciamos el nivel actual

# Función cuando el jugador gana
func _on_victory_panel_closed():
	if actualevel + 1 < arraylevel.size():
		actualevel += 1
		_change_level(actualevel)
	else:
		print("¡Juego completado!")
