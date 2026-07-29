extends ProgressBar

signal jefe_muerto

@export var vida_maxima: float = 1000.0
var vida_actual: float

func _ready() -> void:
	max_value = vida_maxima
	vida_actual = vida_maxima
	value = vida_actual

func recibir_daño(cantidad: float) -> void:
	vida_actual = clampf(vida_actual - cantidad, 0.0, vida_maxima)
	value = vida_actual
	
	if vida_actual <= 0:
		jefe_muerto.emit()
