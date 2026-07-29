extends Area3D
@export var siguiente_escena: String = "res://mundos/mundo1.tscn"

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Jugador":
		if siguiente_escena:
			get_tree().change_scene_to_file(siguiente_escena)
