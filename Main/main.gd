extends Node3D


var timer: float:
	set(value):
		if value >= 2:
			flick($OmniLight3D)
			timer = 0
		else:
			timer = value
	get:
		return timer


func _process(delta: float) -> void:
	timer += randf_range(1,10) * delta
func flick(light: Light3D):
	light.light_energy = randf_range(0.14 , 0.18)






func _on_start_button_pressed() -> void:
	Globals.load_game()
