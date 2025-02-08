extends Node2D

const area_size = 100.0
const radius = 150.0
var num_lines = 20
var angle_offset = 0.0
var is_active = false
var i : int = 0

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var label = $Label
@export var spaceship_scene: PackedScene  # Escena de la nave
@export var spawn_time: float = 5.0  # Tiempo entre generaciones de naves
@export var poblation: int = 42

func _ready() -> void:
	var new_shape = CircleShape2D.new()  # Crear una nueva forma
	new_shape.radius = area_size  # Asignar el radio deseado
	collision_shape.shape = new_shape
	
	animated_sprite.play(get_node(".").name)
	
	label.add_theme_color_override("font_color", Color(0, 0, 255))  # Color azul
	label.add_theme_font_size_override("font_size", 35)
	
	# Crear y configurar el temporizador
	var timer = Timer.new()
	timer.wait_time = spawn_time
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _process(delta):
	if is_active:
		angle_offset += delta * 2.0  # Velocidad de movimiento de las líneas
		queue_redraw()
	update_spaceship_count()

func _draw():
	if is_active:
		for i in range(num_lines):
			var angle = (i * TAU / num_lines) + angle_offset
			var start_pos = Vector2(cos(angle), sin(angle)) * (radius - 5)
			var end_pos = Vector2(cos(angle), sin(angle)) * (radius + 5)
			draw_line(start_pos, end_pos, Color(1, 1, 1), 2)

func _on_area_2d_mouse_entered() -> void:
	is_active = true
	queue_redraw()

func _on_area_2d_mouse_exited() -> void:
	is_active = false
	queue_redraw()

func update_spaceship_count():
	var spaceship_count = 0
	
	# Recorre todos los hijos del nodo (el nodo mismo es el contenedor)
	for spaceship in get_children():
		if spaceship is CharacterBody2D:
			spaceship_count += 1
	
	# Actualizar el texto del Label con la cantidad de naves
	label.text = "-" + str(spaceship_count) + "-"

func _on_timer_timeout():
	if i >= poblation:
		return
	
	var new_spaceship = spaceship_scene.instantiate()
	add_child(new_spaceship)  # Ahora el nodo es el contenedor

	i += 1
