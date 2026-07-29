extends CharacterBody3D

@onready var animation_player = $malla_jugador/AnimationPlayer
@onready var barra_vida = $VidaJugador
@onready var area_ataque = $AreaAtaque/CollisionShape3D
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var malla: Node3D = $malla_jugador
@onready var ropa_1 = $malla_jugador/Armature/Skeleton3D/ropa1
@onready var ropa_2 = $malla_jugador/Armature/Skeleton3D/ropa2
@onready var sonido_muerte = $SonidoMuerte
@onready var pantalla_muerte = $PantallaMuerte
@onready var sonido_ataque = $SonidoAtaque
@onready var sonido_giro = $SonidoGiro

const SPEED = 6.0
const JUMP_VELOCITY = 5.0
const ESQUIVE_SPEED = 12.0
const ROTATION_SPEED = 10.0
const VELOCIDAD_ATAQUE = 3.5

var esta_saltando := false
var esta_atacando := false
var esta_esquivando := false
var esta_envenenado := false  
var esta_muriendo := false 
var direccion_esquive := Vector3.ZERO
var vida := 100.0

func _ready() -> void:
	if area_ataque:
		area_ataque.disabled = true
	GlobalJuego.guardar_posicion_segura(global_position, velocity)
	if GlobalJuego.atuendo_seleccionado == 1:
		if ropa_1: ropa_1.visible = true
		if ropa_2: ropa_2.visible = false
	elif GlobalJuego.atuendo_seleccionado == 2:
		if ropa_1: ropa_1.visible = false
		if ropa_2: ropa_2.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if esta_muriendo:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://mundos/MENU.tscn")

func recibir_daño(cantidad: float) -> void:
	if esta_muriendo:
		return
	if Input.is_action_pressed("cubrirse") or esta_esquivando:
		return
	if barra_vida:
		barra_vida.recibir_daño(cantidad)
	vida -= cantidad
	if vida <= 0:
		morir()

func rebotar_a_suelo_seguro(cantidad_daño: float) -> void:
	recibir_daño(cantidad_daño)
	
	if vida > 0:
		velocity = Vector3.ZERO
		global_position = GlobalJuego.ultima_posicion_segura

func aplicar_veneno() -> void:
	if esta_envenenado:
		return
	esta_envenenado = true
	
	for i in range(5):
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree() or vida <= 0:
			return
		recibir_daño(5.0)
	esta_envenenado = false

func morir() -> void:
	if esta_muriendo:
		return
	esta_muriendo = true
	
	if sonido_muerte:
		sonido_muerte.play()
		
	velocity = Vector3.ZERO
	if area_ataque:
		area_ataque.disabled = true
		
	animation_player.speed_scale = 1.0
	animation_player.play("muerte1")
	
	if not animation_player.animation_finished.is_connected(_al_terminar_animacion):
		animation_player.animation_finished.connect(_al_terminar_animacion)

func _physics_process(delta: float) -> void:
	if esta_muriendo:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		GlobalJuego.guardar_posicion_segura(global_position, velocity)
		
		if esta_saltando:
			animation_player.speed_scale = 1.0
			esta_saltando = false

	var input_dir := Input.get_vector("izquierda", "derecha", "arriba", "abajo")

	var direction := Vector3.ZERO
	if spring_arm:
		var cam_transform = spring_arm.global_transform
		var cam_dir_z = cam_transform.basis.z
		var cam_dir_x = cam_transform.basis.x
		direction = (cam_dir_z * input_dir.y + cam_dir_x * input_dir.x).normalized()
		direction.y = 0
		direction = direction.normalized()
	else:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if esta_esquivando:
		velocity.x = direccion_esquive.x * ESQUIVE_SPEED
		velocity.z = direccion_esquive.z * ESQUIVE_SPEED
	elif esta_atacando:
		velocity.x = 0
		velocity.z = 0
	elif direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		var target_angle = atan2(-direction.x, -direction.z) + PI
		malla.rotation.y = lerp_angle(malla.rotation.y, target_angle, ROTATION_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_just_pressed("esquive") and is_on_floor() and not esta_atacando and not esta_esquivando:
		esta_esquivando = true
		if sonido_giro:
			sonido_giro.play()
		if direction:
			direccion_esquive = direction
		else:
			direccion_esquive = (transform.basis * Vector3(0, 0, 1)).normalized()

		animation_player.speed_scale = 1.3
		animation_player.play("esquivar_adelante")

		if not animation_player.animation_finished.is_connected(_al_terminar_animacion):
			animation_player.animation_finished.connect(_al_terminar_animacion)

	if Input.is_action_just_pressed("saltar") and is_on_floor() and not esta_atacando and not esta_esquivando:
		velocity.y = JUMP_VELOCITY
		animation_player.speed_scale = 0.8
		animation_player.play("saltar_corriendo")
		esta_saltando = true

	if Input.is_action_just_pressed("click_I") and is_on_floor() and not esta_atacando and not esta_esquivando:
		esta_atacando = true
		
		if area_ataque:
			area_ataque.disabled = false

		if sonido_ataque:
			sonido_ataque.play()

		animation_player.speed_scale = VELOCIDAD_ATAQUE
		animation_player.play("ataque_1mano")

		if not animation_player.animation_finished.is_connected(_al_terminar_animacion):
			animation_player.animation_finished.connect(_al_terminar_animacion)

	if not esta_saltando and not esta_atacando and not esta_esquivando:
		if is_on_floor():
			if Input.is_action_pressed("cubrirse"):
				animation_player.speed_scale = 1.0
				animation_player.play("bloqueo")
				velocity.x = 0
				velocity.z = 0
			else:
				animation_player.speed_scale = 1.0
				if direction:
					animation_player.play("correr")
				else:
					animation_player.play("idle")

	move_and_slide()

# --- MODIFICADO: Manejo del final de la animación ---
func _al_terminar_animacion(nombre_animacion: String) -> void:
	animation_player.speed_scale = 1.0

	if nombre_animacion == "muerte1":
		# 1. Liberar el ratón para poder presionar el botón
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# 2. Mostrar la pantalla de reinicio
		if pantalla_muerte:
			pantalla_muerte.show()
			get_tree().paused = true # Pausa la física y enemigos del fondo
	
	if nombre_animacion == "ataque_1mano":
		esta_atacando = false
		if area_ataque:
			area_ataque.disabled = true

	if nombre_animacion == "esquivar_adelante":
		esta_esquivando = false

func _on_area_ataque_body_entered(body: Node3D) -> void:
	if body.name == "boss" or body.is_in_group("boss"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(50.0)
