class_name Hollow extends CharacterBody3D

var chase_speed: float = 3.0
var activated: bool = false
var seen: bool  = false

var target: Node3D = null

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if seen == true:
		return
	else:
		if activated and target:
			chase_target(delta)
			return

	move_and_slide()

func chase_target(delta: float) -> void:

	var direction: Vector3 = target.global_transform.origin - global_transform.origin
	direction.y = 0 
	
	if direction.length() > 0:
		var normalized_direction = direction.normalized()
		var target_angle = atan2(normalized_direction.x, normalized_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 8)
		
		velocity.x = normalized_direction.x * chase_speed
		velocity.z = normalized_direction.z * chase_speed
	else:
		velocity.x = move_toward(velocity.x, 0, chase_speed)
		velocity.z = move_toward(velocity.z, 0, chase_speed)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func activate_npc(target_character: Node3D) -> void:
	activated = true
	target = target_character
