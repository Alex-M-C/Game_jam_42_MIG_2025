extends Node2D

const area_size = 100.0
const radius = 150.0
var num_lines = 20
var angle_offset = 0.0
var is_active = false

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	var new_shape = CircleShape2D.new()  # Crear una nueva forma
	new_shape.radius = area_size  # Asignar el radio deseado
	collision_shape.shape = new_shape
	
	animated_sprite.play(get_node(".").name)

func _process(delta):
	if is_active:
		angle_offset += delta * 2.0  # Velocidad de movimiento de las líneas
		queue_redraw()

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
