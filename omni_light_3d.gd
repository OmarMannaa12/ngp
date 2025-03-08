extends OmniLight3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		self.light_energy = 1

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		self.light_energy = 0
