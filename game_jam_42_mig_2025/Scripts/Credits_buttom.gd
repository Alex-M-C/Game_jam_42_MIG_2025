extends Button

const target_scene_path: String = "res://sub_res/credits.tscn"  # Ruta de la escena de destino

func change_scene() -> void:
	if target_scene_path:
		get_tree().change_scene_to_file(target_scene_path)
	else:
		print("No se ha asignado ninguna ruta de escena en target_scene_path.")

func _on_button_down() -> void:
	change_scene()
