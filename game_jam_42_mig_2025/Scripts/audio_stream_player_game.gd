extends AudioStreamPlayer
var playlist = [
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
