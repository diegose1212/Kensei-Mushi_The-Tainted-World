extends ProgressBar

@export var vida_maxima: float = 1000.0
var vida_actual: float

func _ready():
	max_value = vida_maxima
	vida_actual = vida_maxima
	value = vida_actual

func recibir_daño(cantidad: float):
	vida_actual -= cantidad
	value = vida_actual 
	
