extends CharacterBody3D

@onready var movimiento = $mallaBoss/AnimationPlayer
@onready var barra_vida = $barra_boss
@onready var collision_principal: CollisionShape3D = $CollisionShape3D 
@onready var area_mordisco: Area3D = $AreaMordisco
@onready var area_mordisco_colision: CollisionShape3D = $AreaMordisco/CollisionShape3D

# --- NODOS DE SONIDO ---
@onready var sonido_ataque = $SonidoAtaque
# (Opcional) Si agregas nodos extra en el boss para sus otros ataques:
@onready var sonido_veneno = $SonidoVeneno if has_node("SonidoVeneno") else null
@onready var sonido_subterraneo = $SonidoSubterraneo if has_node("SonidoSubterraneo") else null

const VELOCIDAD_BOSS = 1.0
const DISTANCIA_DETECCION = 15.0
const DISTANCIA_ATAQUE = 2.2
const DAÑO_MORDISCO = 35.0  
const COOLDOWN_ATAQUE = 2.0 

const COOLDOWN_VENENO = 5.0 
const ESCENA_BOLA_VENENO = preload("res://mundos/bola_veneno.tscn") 
var puede_lanzar_veneno := true

const COOLDOWN_SUBTERRANEO = 8.0
var puede_atacar_subterraneo := true
var esta_haciendo_subterraneo := false
var esta_muriendo := false

var nodo_jugador: CharacterBody3D = null
var esta_atacando := false
var puede_atacar := true

func recibir_daño(cantidad: float) -> void:
	if esta_muriendo:
		return
	if barra_vida:
		barra_vida.recibir_daño(cantidad)

func _on_jefe_muerto() -> void:
	if esta_muriendo:
		return
	esta_muriendo = true
	
	velocity = Vector3.ZERO
	if collision_principal:
		collision_principal.disabled = true
	if area_mordisco_colision:
		area_mordisco_colision.disabled = true
		
	if movimiento:
		movimiento.stop()
		movimiento.speed_scale = 0.7 
		movimiento.play("animacion_muerte")

func _ready() -> void:
	if barra_vida:
		barra_vida.jefe_muerto.connect(_on_jefe_muerto)
		
	if movimiento:
		movimiento.animation_finished.connect(_al_terminar_animacion)
		movimiento.play("movimiento_normal")
	
	if get_parent().has_node("jugador"):
		nodo_jugador = get_parent().get_node("jugador") as CharacterBody3D

	if area_mordisco_colision:
		area_mordisco_colision.disabled = true

	var timer_veneno = Timer.new()
	timer_veneno.wait_time = COOLDOWN_VENENO
	timer_veneno.autostart = true
	timer_veneno.one_shot = false
	timer_veneno.timeout.connect(_intentar_lanzar_veneno)
	add_child(timer_veneno)

	var timer_subterraneo = Timer.new()
	timer_subterraneo.wait_time = COOLDOWN_SUBTERRANEO
	timer_subterraneo.autostart = true
	timer_subterraneo.one_shot = false
	timer_subterraneo.timeout.connect(_intentar_ataque_subterraneo)
	add_child(timer_subterraneo)

func _physics_process(delta: float) -> void:
	if esta_muriendo:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	if is_instance_valid(nodo_jugador) and not esta_atacando:
		var distancia = global_position.distance_to(nodo_jugador.global_position)
		
		if distancia <= DISTANCIA_DETECCION:
			var posicion_objetivo = nodo_jugador.global_position
			posicion_objetivo.y = global_position.y 
			
			look_at(posicion_objetivo, Vector3.UP)
			rotate_y(deg_to_rad(180))
			
			if distancia <= DISTANCIA_ATAQUE and puede_atacar:
				velocity.x = 0
				velocity.z = 0
				esta_atacando = true
				puede_atacar = false
				
				# --- SONIDO: ATAQUE DE MORDISCO ---
				if sonido_ataque:
					sonido_ataque.play()
					
				if movimiento:
					movimiento.play("ataque_mordisco")
			else:
				var direccion = (nodo_jugador.global_position - global_position)
				direccion.y = 0 
				direccion = direccion.normalized()
				
				velocity.x = direccion.x * VELOCIDAD_BOSS
				velocity.z = direccion.z * VELOCIDAD_BOSS
				if movimiento and movimiento.current_animation != "movimiento_normal" and not esta_atacando:
					movimiento.play("movimiento_normal")
		else:
			_detener_movimiento()
	elif not is_instance_valid(nodo_jugador):
		_detener_movimiento()
	
	if esta_haciendo_subterraneo and is_instance_valid(nodo_jugador):
		var dir_sub = (nodo_jugador.global_position - global_position)
		dir_sub.y = 0
		dir_sub = dir_sub.normalized()
		velocity.x = dir_sub.x * 4.0 
		velocity.z = dir_sub.z * 4.0

	move_and_slide()

func _detener_movimiento() -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD_BOSS)
		velocity.z = move_toward(velocity.z, 0, VELOCIDAD_BOSS)
		if movimiento and movimiento.current_animation != "movimiento_normal" and not esta_atacando:
			movimiento.play("movimiento_normal")

func _intentar_lanzar_veneno() -> void:
	if esta_muriendo or not is_instance_valid(nodo_jugador) or esta_atacando:
		return
		
	var distancia = global_position.distance_to(nodo_jugador.global_position)
	if distancia > 3.0 and distancia <= 12.0 and puede_lanzar_veneno:
		esta_atacando = true
		puede_lanzar_veneno = false
		velocity.x = 0
		velocity.z = 0
		
		var posicion_objetivo = nodo_jugador.global_position
		posicion_objetivo.y = global_position.y 
		look_at(posicion_objetivo, Vector3.UP)
		rotate_y(deg_to_rad(180))
		
		# --- SONIDO: LANZAR VENENO ---
		if sonido_veneno:
			sonido_veneno.play()
		elif sonido_ataque:
			sonido_ataque.play()
		
		if movimiento:
			movimiento.play("ataque_bolas_veneno")
			
		await get_tree().create_timer(0.4).timeout
		if is_instance_valid(nodo_jugador):
			_disparar_rafaga_veneno()
			
		var timer_cd = get_tree().create_timer(6.0)
		timer_cd.timeout.connect(func(): puede_lanzar_veneno = true)

func _intentar_ataque_subterraneo() -> void:
	if esta_muriendo or not is_instance_valid(nodo_jugador) or esta_atacando:
		return
		
	var distancia = global_position.distance_to(nodo_jugador.global_position)
	if distancia <= 14.0 and puede_atacar_subterraneo:
		esta_atacando = true
		puede_atacar_subterraneo = false
		esta_haciendo_subterraneo = true
		
		if collision_principal:
			collision_principal.disabled = true
		
		# --- SONIDO: ENTRAR AL SUELO ---
		if sonido_subterraneo:
			sonido_subterraneo.play()
		elif sonido_ataque:
			sonido_ataque.play()
		
		if movimiento:
			movimiento.play("ataque_subterraneo")
			
		aplicar_mordisco_subterraneo()

func aplicar_mordisco_subterraneo() -> void:
	if not area_mordisco_colision:
		return

	await get_tree().create_timer(8.5).timeout
	if esta_muriendo: return
	
	area_mordisco_colision.disabled = false
	
	await get_tree().process_frame
	_comprobar_daño_mordisco()
	
	await get_tree().create_timer(1.0).timeout
	if esta_muriendo: return
	
	area_mordisco_colision.disabled = true
		
	await get_tree().create_timer(2.5).timeout
	if esta_muriendo: return
	
	area_mordisco_colision.disabled = false
	
	await get_tree().process_frame
	_comprobar_daño_mordisco()
	await get_tree().create_timer(1.0).timeout
	if esta_muriendo: return
	
	area_mordisco_colision.disabled = true

func _comprobar_daño_mordisco() -> void:
	if not is_instance_valid(nodo_jugador) or not is_instance_valid(area_mordisco):
		return
		
	var cuerpos_en_area = area_mordisco.get_overlapping_bodies()
	
	if nodo_jugador in cuerpos_en_area or global_position.distance_to(nodo_jugador.global_position) <= 3.5:
		if nodo_jugador.has_method("recibir_daño"):
			nodo_jugador.recibir_daño(30.0)
		elif "vida" in nodo_jugador:
			nodo_jugador.vida -= 30.0

func _disparar_rafaga_veneno() -> void:
	if ESCENA_BOLA_VENENO and is_instance_valid(nodo_jugador):
		var bola1 = ESCENA_BOLA_VENENO.instantiate()
		get_parent().add_child(bola1)
		bola1.lanzar(global_position + Vector3(0, 1.5, 0), nodo_jugador.global_position)
	
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(nodo_jugador): return
	
	if ESCENA_BOLA_VENENO:
		var bola2 = ESCENA_BOLA_VENENO.instantiate()
		get_parent().add_child(bola2)
		bola2.lanzar(global_position + Vector3(0, 1.5, 0), nodo_jugador.global_position)
		
	await get_tree().create_timer(0.6).timeout
	if not is_instance_valid(nodo_jugador): return
	
	if ESCENA_BOLA_VENENO:
		var bola3 = ESCENA_BOLA_VENENO.instantiate()
		get_parent().add_child(bola3)
		var origen_izq = global_position + Vector3(0, 2, -0.1) - (global_transform.basis.x * 0.8)
		bola3.lanzar(origen_izq, nodo_jugador.global_position)
		
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(nodo_jugador): return
	
	if ESCENA_BOLA_VENENO:
		var bola4 = ESCENA_BOLA_VENENO.instantiate()
		get_parent().add_child(bola4)
		var origen_der = global_position + Vector3(0, 1.2, 0) + (global_transform.basis.x * 0.8)
		bola4.lanzar(origen_der, nodo_jugador.global_position)
		
func _al_terminar_animacion(nombre_animacion: String) -> void:
	if nombre_animacion == "animacion_muerte":
		queue_free()
		return

	if nombre_animacion == "ataque_mordisco":
		esta_atacando = false
		if is_instance_valid(nodo_jugador) and global_position.distance_to(nodo_jugador.global_position) <= (DISTANCIA_ATAQUE + 0.5):
			if nodo_jugador.has_method("recibir_daño"):
				nodo_jugador.recibir_daño(DAÑO_MORDISCO)
		if movimiento:
			movimiento.play("movimiento_normal")
		var timer = get_tree().create_timer(COOLDOWN_ATAQUE)
		timer.timeout.connect(func(): puede_atacar = true)

	elif nombre_animacion == "ataque_bolas_veneno":
		esta_atacando = false
		if movimiento:
			movimiento.play("movimiento_normal")
			
	elif nombre_animacion == "ataque_subterraneo":
		esta_haciendo_subterraneo = false
		velocity.x = 0
		velocity.z = 0
		
		await get_tree().create_timer(3.0).timeout
		if esta_muriendo: return
		
		if movimiento:
			movimiento.play("salir_subterraneo")

	elif nombre_animacion == "salir_subterraneo":
		if collision_principal:
			collision_principal.disabled = false
		
		esta_atacando = false
		if movimiento:
			movimiento.play("movimiento_normal")
			
		var timer_sub = get_tree().create_timer(10.0)
		timer_sub.timeout.connect(func(): puede_atacar_subterraneo = true)
	
	elif nombre_animacion == "movimiento_normal" and not esta_atacando:
		if movimiento:
			movimiento.play("movimiento_normal")

func _on_area_mordisco_body_entered(body: Node3D) -> void:
	if body == nodo_jugador or body.name == "jugador":
		if body.has_method("recibir_daño"):
			body.recibir_daño(30.0)
		elif "vida" in body:
			body.vida -= 30.0
