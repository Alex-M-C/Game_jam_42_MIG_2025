extends AudioStreamPlayer
var playlist = [
	preload("res://mmusica/Unknown_AI.mp3"),
	preload("res://mmusica/Untitled (5).wav"),
	preload("res://mmusica/space game (1).wav"),
	preload("res://mmusica/Untitled (4).wav"),
	preload("res://mmusica/Galactic Odyssey.wav"),
	preload("res://mmusica/space game.wav")
]
var current_track = 0
func _ready():
	stream = playlist[current_track]  # Asigna la primera canción
	play()  # Inicia la reproducción
	connect("finished", Callable(self, "_on_track_finished"))  # Conectar la señal
func _on_track_finished():
	current_track += 1
	if current_track < playlist.size():
		stream = playlist[current_track]  # Cambia a la siguiente canción
		play()
	else:
		current_track = 0  # Reinicia la playlist si quieres un loop
