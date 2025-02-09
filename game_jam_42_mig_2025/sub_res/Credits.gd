extends Node2D

@export var velocidad = 50  # Ajusta la velocidad del desplazamiento
@onready var sound_player = $AudioStreamPlayer2D  
@onready var texto = $credits  

var tamano_fuente = 5
var indice = 0

# Lista de créditos con BBCode
var nombres = [
	"[font_size=" + str(tamano_fuente + 20) + "][color=White]SPACE-CARNIVAL: First contact[/color][/font_size]\n\n",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red]CREDITS[/color][/font_size]\n\n",
	"[color=Lime]Alex Mihai Constantiniu (Más fedeado que la Q de Nasus en late)[/color]",
	"[color=lime]Alejandro Jiménez(Buffeado por el bien de la trama)[/color]",
	"[color=lime]Juan David Laverde(Aprendió a usar Godot y Gimp (no durmió))[/color]",
	"[color=lime]Iván de Diego Megía (Chat GPT le pide ayuda a él (está loco))[/color]",
	"[color=Lime]Ismael Hernández (Pasó, hackeó la Matrix y la renderizó en 2D(Pasquale Rossi 2.0))[/color]"
]

func _ready():
	if not texto:
		push_error("Error: No se encontró el nodo 'credits'")
		return

	texto.bbcode_enabled = true  
	texto.text = "\n".join(nombres)  # Ahora seteamos todo el texto de una vez
	texto.custom_minimum_size = Vector2(600, 400)  
	texto.size = Vector2(600, 400)  

	# Coloca el texto debajo de la pantalla para que suba
	texto.position.y = get_viewport_rect().size.y + 50  

	if sound_player and not sound_player.playing:
		sound_player.play()

func _process(delta):
	# Mueve el texto hacia arriba
	texto.position.y -= velocidad * delta  

	# Reinicio si el texto ha salido completamente de la pantalla
	if texto.position.y + texto.size.y < 0:
		texto.position.y = get_viewport_rect().size.y + 50  
