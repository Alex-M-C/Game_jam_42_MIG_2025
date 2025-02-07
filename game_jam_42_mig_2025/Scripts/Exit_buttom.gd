extends Button

func _on_Button_pressed():
	# Salir del juego
	get_tree().quit()


func _on_button_down() -> void:
	get_tree().quit()


func _on_button_up() -> void:
	pass # Replace with function body.
