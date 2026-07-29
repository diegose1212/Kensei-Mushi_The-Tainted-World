extends Camera3D

@export var sensibilidad_mouse: float = 0.003
@export var distancia_al_objetivo: float = 4.0 # Distancia que tendrá la cámara respecto al personaje
@export var limite_inferior: float = -89.0
@export var limite_superior: float = 89.0

# Usaremos un nodo padre (o pivote) para rotar alrededor del jugador
@onready var objetivo: Node3D = get_parent() 

var rotacion_x: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("salir"):
		get_tree().quit()
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotar al personaje horizontalmente con el movimiento en X del mouse
		objetivo.rotate_y(-event.relative.x * sensibilidad_mouse)
		
		# Acumular y limitar la rotación vertical
		rotacion_x -= event.relative.y * sensibilidad_mouse
		rotacion_x = clamp(rotacion_x, deg_to_rad(limite_inferior), deg_to_rad(limite_superior))
		
		# Aplicar la rotación vertical y mantener la distancia orbital
		transform.basis = Basis() # Reiniciar rotación de la cámara
		rotate_object_local(Vector3.RIGHT, rotacion_x) # Rotar arriba/abajo
		
		# Recalcular la posición manteniendo la distancia respecto al objetivo
		# (Asumiendo que la cámara está como hija directa o se alinea al origen del jugador)
		global_position = objetivo.global_position - (transform.basis.z * distancia_al_objetivo) + Vector3(0, 1.5, 0) # Altura de los ojos/pecho del personaje
