extends Node

var atuendo_seleccionado: int = 1
var ultima_posicion_segura: Vector3 = Vector3.ZERO

func guardar_posicion_segura(pos: Vector3, velocidad_actual: Vector3) -> void:
	var retroceso = Vector3.ZERO
	if velocidad_actual.length() > 0.1:
		retroceso = -velocidad_actual.normalized() * 0.8
	
	ultima_posicion_segura = pos + retroceso
