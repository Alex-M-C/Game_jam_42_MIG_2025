extends Node

@export var game_manager: Node2D
@export var decision_interval: float = 5.0  # Tiempo entre decisiones de la IA
var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = decision_interval
	timer.autostart = true
	timer.timeout.connect(_on_decision_timer_timeout)
	add_child(timer)

func _on_decision_timer_timeout():
	var enemy_planets = []
	var target_planets = []
	
	for planet in game_manager.planets:
		if planet.planet_status == 2:  # Planetas de la IA enemiga
			enemy_planets.append(planet)
		elif planet.planet_status != 2:  # Planetas del jugador o deshabitados
			target_planets.append(planet)
	
	if enemy_planets.size() > 0 and target_planets.size() > 0:
		var origin_planet = enemy_planets[randi() % enemy_planets.size()]
		var target_planet = target_planets[randi() % target_planets.size()]
		
		var ships_to_send = []
		for ship in origin_planet.get_children():
			if ship.is_in_group("spaceships") and ship.faction == 2:
				ships_to_send.append(ship)
		
		var half_ships = ships_to_send.size() / 2
		for j in range(half_ships):
			var ship = ships_to_send[j]
			ship.travel_to(target_planet.global_position, target_planet)
