extends Node2D

const area_size = 100.0
const radius = 150.0
var is_active = false
var angle_offset = 0.0  
var i : int = 0

var in_battle: bool = false  

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label = $Label

@export var spaceship_scene: PackedScene
@export var spawn_time: float = 5.0
@export var poblation: int = 42
@export var planet_status: int

var timer: Timer  

func _ready():
	var new_shape = CircleShape2D.new()
	new_shape.radius = area_size
	collision_shape.shape = new_shape
	
	animated_sprite.play(get_node(".").name)
	_update_label_color()

	timer = Timer.new()
	timer.wait_time = spawn_time
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	if planet_status == 1 or planet_status == 2:
		var new_spaceship = spaceship_scene.instantiate()
		new_spaceship.faction = planet_status
		add_child(new_spaceship)
		i = 1  

func _process(delta):
	angle_offset += delta * 2.0  
	queue_redraw()
	_update_spaceship_count()
	_check_for_battle()

func _draw():
	if is_active:  
		var line_color = Color(1, 1, 1)
		if planet_status == 1:
			line_color = Color(0.3, 0.5, 1)
		elif planet_status == 2:
			line_color = Color(1, 0.3, 0.3)
		elif planet_status == 3:
			line_color = Color(1, 1, 0.3)
		
		for i in range(20):
			var angle = (i * TAU / 20) + angle_offset
			var start_pos = Vector2(cos(angle), sin(angle)) * (radius - 5)
			var end_pos = Vector2(cos(angle), sin(angle)) * (radius + 5)
			draw_line(start_pos, end_pos, line_color, 2)

func _update_label_color():
	if planet_status == 0:
		label.add_theme_color_override("font_color", Color(255, 255, 255))  # Neutral
	elif planet_status == 1:
		label.add_theme_color_override("font_color", Color(0, 0, 255))  # Humanos
	elif planet_status == 2:
		label.add_theme_color_override("font_color", Color(255, 0, 0))  # Enemigos
	elif planet_status == 3:
		label.add_theme_color_override("font_color", Color(255, 255, 0))  # Combate (amarillo)

func _update_spaceship_count():
	var ships = get_children().filter(func(ship): return ship is Node2D and ship.is_in_group("spaceships"))
	var count_human = ships.filter(func(ship): return ship.faction == 1).size()
	var count_enemy = ships.filter(func(ship): return ship.faction == 2).size()
	label.text = "H: " + str(count_human) + " E: " + str(count_enemy)

	if count_human == 0 and count_enemy == 0:
		planet_status = 0
		_update_label_color()

func _check_for_battle():
	var ships = get_children().filter(func(ship): return ship is Node2D and ship.is_in_group("spaceships"))
	var human_ships = ships.filter(func(ship): return ship.faction == 1)
	var enemy_ships = ships.filter(func(ship): return ship.faction == 2)

	if human_ships.size() > 0 and enemy_ships.size() > 0:
		if not in_battle:
			in_battle = true  
			timer.stop()  
			planet_status = 3  # 🔥 Se pone en estado de combate (amarillo)
			_update_label_color()
			print("🔥 Batalla iniciada: generación de naves pausada.") 
		
		await get_tree().create_timer(0.5).timeout
		if human_ships.size() > 0 and is_instance_valid(human_ships[0]):
			human_ships[0].queue_free()
		if enemy_ships.size() > 0 and is_instance_valid(enemy_ships[0]):
			enemy_ships[0].queue_free()
	else:
		if in_battle:
			in_battle = false  
			_decide_new_owner()  # 🔥 Cambia el dueño del planeta si hay ganador
			if _can_generate_more_ships():
				timer.start()  
			print("✅ Batalla terminada: nuevo dueño del planeta.")

func _decide_new_owner():
	var ships = get_children().filter(func(ship): return ship is Node2D and ship.is_in_group("spaceships"))
	var count_human = ships.filter(func(ship): return ship.faction == 1).size()
	var count_enemy = ships.filter(func(ship): return ship.faction == 2).size()

	if count_human > 0:
		planet_status = 1  # 🔵 Humanos ganan el planeta
	elif count_enemy > 0:
		planet_status = 2  # 🔴 Enemigos ganan el planeta
	else:
		planet_status = 0  # ⚪ Neutral

	_update_label_color()
	i = 0  # 🔄 Reseteamos la cantidad de naves generadas
	print("🏆 Nuevo dueño del planeta:", planet_status)

func _on_timer_timeout():
	if planet_status == 0 or planet_status == 3 or i >= poblation or in_battle or not _can_generate_more_ships():
		print("🚫 Generación de naves bloqueada.")
		return  

	var new_spaceship = spaceship_scene.instantiate()
	new_spaceship.faction = planet_status
	add_child(new_spaceship)
	i += 1
	print("🛸 Nave generada para el equipo", planet_status, "- Total:", i)

func _can_generate_more_ships() -> bool:
	var ships = get_children().filter(func(ship): return ship is Node2D and ship.is_in_group("spaceships"))
	return ships.size() < poblation  # ✅ Si hay menos naves que el máximo, se pueden generar más.

func _on_area_2d_mouse_entered() -> void:
	is_active = true
	queue_redraw()

func _on_area_2d_mouse_exited() -> void:
	is_active = false
	queue_redraw()
