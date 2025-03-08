extends Node3D

var timer: float:
	set(value):
		if value >= 1:
			flick($OmniLight3D)
			timer = 0
		else:
			timer = value
	get:
		return timer
func _ready() -> void:
	$Player/CanvasLayer/Label.visible = false
	$Hollow.activate_npc($Player)

func _process(delta: float) -> void:
	timer += randf_range(1,10) * delta
func flick(light: Light3D):
	light.light_energy = randf_range(0.3 , 0.6)
