extends Control

func _ready():
	$VBoxContainer/BtnJugar.pressed.connect(_on_jugar)
	$VBoxContainer/BtnPersonajes.pressed.connect(_on_personajes)
	$VBoxContainer/BtnSalir.pressed.connect(_on_salir)
	_aplicar_estilo()

func _aplicar_estilo():
	var botones = [$VBoxContainer/BtnJugar, $VBoxContainer/BtnPersonajes, $VBoxContainer/BtnSalir]
	for btn in botones:
		var estilo_normal = StyleBoxFlat.new()
		estilo_normal.bg_color = Color(0.05, 0.05, 0.05)
		estilo_normal.border_color = Color(0.5, 0.0, 0.0)
		estilo_normal.border_width_top = 1
		estilo_normal.border_width_bottom = 1
		estilo_normal.border_width_left = 1
		estilo_normal.border_width_right = 1
		btn.add_theme_stylebox_override("normal", estilo_normal)

		var estilo_hover = StyleBoxFlat.new()
		estilo_hover.bg_color = Color(0.15, 0.0, 0.0)
		estilo_hover.border_color = Color(0.8, 0.0, 0.0)
		estilo_hover.border_width_top = 1
		estilo_hover.border_width_bottom = 1
		estilo_hover.border_width_left = 1
		estilo_hover.border_width_right = 1
		btn.add_theme_stylebox_override("hover", estilo_hover)

		btn.add_theme_color_override("font_color", Color(0.8, 0.7, 0.6))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
		btn.add_theme_font_size_override("font_size", 16)

func _on_jugar():
	get_tree().change_scene_to_file("res://mundos/mundo_1.tscn")

func _on_personajes():
	get_tree().change_scene_to_file("res://personajes/seleccion_personajes.tscn")

func _on_salir():
	get_tree().quit()
