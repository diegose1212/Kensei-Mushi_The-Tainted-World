extends Button

@onready var sonido_clic = $SonidoClic

func _on_pressed() -> void:
	# 1. Desactivar el botón para evitar clics dobles continuos
	disabled = true
	
	# 2. Reproducir el sonido y esperar a que termine
	if sonido_clic and sonido_clic.stream:
		sonido_clic.play()
		await sonido_clic.finished # Espera a que termine el audio antes de destruir la escena
	else:
		await get_tree().create_timer(0.15).timeout # Resguardo si no hay archivo de audio asignado
		
	# 3. Quitar la pausa y reiniciar el nivel
	get_tree().paused = false
	get_tree().reload_current_scene()
