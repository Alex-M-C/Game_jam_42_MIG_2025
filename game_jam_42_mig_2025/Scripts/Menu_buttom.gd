extends Button

const menu_scene_path: String = "res://Scenes/menu.tscn"  # Ruta de la escena del menú

func change_scene() -> void:
	if menu_scene_path:
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		print("No se ha asignado ninguna ruta de escena en menu_scene_path.")

func _on_Button_pressed() -> void:
	change_scene()

func _on_button_down() -> void:
	change_scene()
