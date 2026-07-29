extends Node3D

@onready var anim_player: AnimationPlayer = $Jugador2/malla_jugador/AnimationPlayer
@onready var jugador = $Jugador2
@onready var barra_vida = $Jugador2/VidaJugador
@onready var ropa_1: MeshInstance3D = $Jugador2/malla_jugador/Armature/Skeleton3D/ropa1
@onready var ropa_2: MeshInstance3D = $Jugador2/malla_jugador/Armature/Skeleton3D/ropa2
@onready var btn_ropa_1: Button = $CanvasLayer/Control/Button
@onready var btn_ropa_2: Button = $CanvasLayer/Control/Button2
@onready var btn_regresar: Button = $CanvasLayer/Control/Button3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if jugador and jugador.get_script():
		jugador.set_script(null)
		
	if anim_player and anim_player.has_animation("caminar"):
		var anim = anim_player.get_animation("caminar")
		anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play("caminar")
		
	if barra_vida:
		barra_vida.visible = false

	actualizar_atuendo_visual(GlobalJuego.atuendo_seleccionado)
	btn_ropa_1.pressed.connect(_on_ropa_1_pressed)
	btn_ropa_2.pressed.connect(_on_ropa_2_pressed)
	btn_regresar.pressed.connect(_on_regresar_pressed)
func _on_ropa_1_pressed() -> void:
	GlobalJuego.atuendo_seleccionado = 1
	actualizar_atuendo_visual(1)

func _on_ropa_2_pressed() -> void:
	GlobalJuego.atuendo_seleccionado = 2
	actualizar_atuendo_visual(2)

func actualizar_atuendo_visual(id: int) -> void:
	if id == 1:
		if ropa_1: ropa_1.visible = true
		if ropa_2: ropa_2.visible = false
	elif id == 2:
		if ropa_1: ropa_1.visible = false
		if ropa_2: ropa_2.visible = true


func _on_regresar_pressed() -> void:
	get_tree().change_scene_to_file("res://mundos/MENU.tscn")
