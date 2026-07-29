extends Area3D

const DAÑO = 10.0
const DURACION_VUELO = 0.25
const ALTURA_ARCO = 3.5

var punto_inicio := Vector3.ZERO
var punto_destino := Vector3.ZERO
var tiempo_transcurrido := 0.0
var en_vuelo := false

func lanzar(desde: Vector3, hacia: Vector3) -> void:
	punto_inicio = desde
	punto_destino = hacia
	global_position = desde
	tiempo_transcurrido = 0.0
	en_vuelo = true

func _physics_process(delta: float) -> void:
	if not en_vuelo:
		return
		
	tiempo_transcurrido += delta
	var t = clamp(tiempo_transcurrido / DURACION_VUELO, 0.0, 1.0)
	
	var posicion_horizontal = punto_inicio.lerp(punto_destino, t)
	var altura_extra = sin(t * PI) * ALTURA_ARCO
	global_position = Vector3(
		posicion_horizontal.x,
		posicion_horizontal.y + altura_extra,
		posicion_horizontal.z
	)
	var jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		jugador = get_tree().root.get_node_or_null("mundo1/jugador") 
		
	if jugador and global_position.distance_to(jugador.global_position) < 1.2:
		if jugador.has_method("recibir_daño"):
			jugador.recibir_daño(DAÑO)
		if jugador.has_method("aplicar_veneno"):
			jugador.aplicar_veneno()
		queue_free()
		return
	
	if t >= 1.0:
		queue_free()
