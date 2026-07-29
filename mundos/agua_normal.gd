extends Area3D

@export var damage_amount: float = 10.0

func _on_body_entered(body: Node3D):
	
	if body.name == "Jugador" or body.is_in_group("jugador") or body.is_in_group("Player"):
		
		if body.has_method("rebotar_a_suelo_seguro"):
			body.rebotar_a_suelo_seguro(damage_amount)
