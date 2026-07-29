extends SpringArm3D

@export var sensibilidad_mouse: float = 0.003
@export var limite_inferior: float = -60.0
@export var limite_superior: float = 60.0

var cam_rot_x: float = 0.0
var cam_rot_y: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cam_rot_x = rotation.x
	cam_rot_y = rotation.y

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("salir"):
		get_tree().quit()
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Acumula el giro horizontal exclusivamente con el mouse
		cam_rot_y -= event.relative.x * sensibilidad_mouse
		rotation.y = cam_rot_y
			
		# Acumula y limita el giro vertical del brazo
		cam_rot_x -= event.relative.y * sensibilidad_mouse
		cam_rot_x = clamp(cam_rot_x, deg_to_rad(limite_inferior), deg_to_rad(limite_superior))
		rotation.x = cam_rot_x
