extends Control

@onready var rich_text_label = $RichTextLabel
@onready var sound_player = $AudioStreamPlayer2D
@onready var marvin_sprite = $Marvin_sprite  # AnimatedSprite2D
@onready var varkos_sprite = $Varkos_sprite
@onready var animation_player = varkos_sprite.get_node("AnimationPlayer")

var tamano_fuente = 5
var historia_texto_marvin = [
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](Transmitiendo...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Blue]Comandante![/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Blue]Soy Marvin y seré su asistente de operaciones[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Blue]Por favor, siga mis instrucciones[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=red]Iniciando Protocolo de Combate...[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red]Haciendo click izquierdo sobre nuestro planeta seleccionará la mitad de su flota de combate[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red]Luego seleccione su objetivo haciendo click sobre el planeta que desea atacar[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red]Nuestras flotas atacarán después de esta acción[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Blue]Bien hecho comandante! lo ha entendido...[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Blue]Ya estamos listos para liberar al universo de los Críptidos y expandir nuestro carnaval a cada rincón del espacio exterior[/color][/font_size]"
]

var historia_texto_varkos = [
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](Transmitiendo...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Black]Comandante, le habla el General Varkos, jefe supremo de la legión Criptodiana[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Black]Prepare sus flotas pues no hay vuelta atrás, es inminente la guerra espacial...[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Brown]Durante siglos su especie inmunda se ha atribuido el derecho de consumir todo a su paso...[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Brown]No conocemos la misericordia ni la piedad, aborrecemos toda su estirpe de simios danzantes y todo festejo carnavalesco y pueril[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Brown]No hay lugar en el abismo para el escándalo y la algarabia humana...[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]",
	"[font_size=" + str(tamano_fuente + 13) + "][color=Red](...)[/color][/font_size]"
]

var indice_marvin = 0
var indice_varkos = 0
var escribiendo = false
var tiempo_entre_letras = 0.05
var tiempo_acelerado = 0.01
var frame_indice = 0

func _ready():
	rich_text_label.bbcode_enabled = true
	sound_player = get_node("AudioStreamPlayer2D")

	if not sound_player.playing:
		sound_player.play()

	if marvin_sprite is AnimatedSprite2D:
		marvin_sprite.play()

	# Verificamos si la referencia de animation_player está correcta
	print(animation_player)

	mostrar_texto_marvin()

# Mostrar el texto de Marvin en la interfaz
func mostrar_texto_marvin():
	if indice_marvin < historia_texto_marvin.size():
		escribiendo = true
		await escribir_texto(historia_texto_marvin[indice_marvin])
		escribiendo = false
		# Avanzar a la siguiente línea de texto al finalizar el actual
		indice_marvin += 1

# Escribir el texto con retardo
func escribir_texto(texto):
	rich_text_label.text = texto
	await get_tree().create_timer(tiempo_entre_letras).timeout  # Esperamos el tiempo entre letras

# Capturar eventos del teclado y mouse
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		procesar_clic()

	elif event is InputEventKey and event.pressed and event.scancode == KEY_SPACE:
		procesar_clic()

# Función para manejar clics y animaciones
func procesar_clic():
	if escribiendo:
		tiempo_entre_letras = tiempo_acelerado  # Acelerar escritura
	else:
		# Si es el final del diálogo de Marvin, iniciamos la entrada de Varkos
		if indice_marvin >= historia_texto_marvin.size():
			# Animación de salida de Marvin y entrada de Varkos
			mostrar_salida_marvin()
		else:
			# Avanzar al siguiente texto
			mostrar_texto_marvin()

# Animar la salida de Marvin
func mostrar_salida_marvin():
	marvin_sprite.visible = false  # Eliminar a Marvin de la vista
	# Una vez Marvin sale, activamos la entrada de Varkos
	mostrar_texto_varkos()

# Mostrar el texto de Varkos
func mostrar_texto_varkos():
	if indice_varkos < historia_texto_varkos.size():
		escribiendo = true
		await escribir_texto(historia_texto_varkos[indice_varkos])
		escribiendo = false
		# Avanzar a la siguiente línea de texto al finalizar el actual
		indice_varkos += 1
