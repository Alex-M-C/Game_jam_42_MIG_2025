extends Node2D

var ai_planets: Array[Node2D] = []
var enemy_planets: Array[Node2D] = []
var neutral_planets: Array[Node2D] = []

func _ready():
	categorize_planets()
	var ai_timer = Timer.new()
	ai_timer.wait_time = 2.0
	ai_timer.autostart = true
	ai_timer.timeout.connect(_on_ai_decision)
	add_child(ai_timer)

func categorize_planets():
	ai_planets.clear()
	enemy_planets.clear()
	neutral_planets.clear()
	
	var game_manager = get_parent()
	var planets = game_manager.planets
	
	for planet in planets:
		match planet.planet_status:
			2: ai_planets.append(planet)
			1: enemy_planets.append(planet)
			0: neutral_planets.append(planet)

func _on_ai_decision():
	categorize_planets()
	if ai_planets.is_empty():
		return
	
	var action = randi_range(0, 2)
	match action:
		0: expand_to_neutral()
		1: attack_enemy()
		2: reinforce_planets()

func expand_to_neutral():
	if neutral_planets.is_empty() or ai_planets.is_empty():
		return
	
	var from_planet = get_strongest_planet(ai_planets)
	var to_planet = get_weakest_planet(neutral_planets)
	send_ships(from_planet, to_planet)

func attack_enemy():
	if enemy_planets.is_empty() or ai_planets.is_empty():
		return
	
	var from_planet = get_strongest_planet(ai_planets)
	var to_planet = get_weakest_planet(enemy_planets)
	send_ships(from_planet, to_planet)

func reinforce_planets():
	if ai_planets.size() < 2:
		return
	
	var from_planet = get_strongest_planet(ai_planets)
	var to_planet = get_weakest_planet(ai_planets)
	send_ships(from_planet, to_planet)

func send_ships(from_planet: Node2D, to_planet: Node2D):
	var ships_to_send = []
	for ship in from_planet.get_children():
		if ship.is_in_group("spaceships") and ship.faction == 2:
			ships_to_send.append(ship)
	
	var half_ships = ships_to_send.size() / 2
	for j in range(half_ships):
		var ship = ships_to_send[j]
		ship.travel_to(to_planet.global_position, to_planet)

func get_strongest_planet(planets_list: Array) -> Node2D:
	planets_list.sort_custom(func(a, b): return a.get_script().has_method("ship_count") and a.ship_count > b.ship_count)
	return planets_list.front()

func get_weakest_planet(planets_list: Array) -> Node2D:
	planets_list.sort_custom(func(a, b): return a.get_script().has_method("ship_count") and a.ship_count < b.ship_count)
	return planets_list.front()
