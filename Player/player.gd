class_name Player extends CharacterBody3D

var SPEED: float = 2.0:
		set(value):
			if value <= 1:
				SPEED = 1
			else:
				SPEED = value
			bob_value = Vector2(SPEED / 200,  SPEED / 60)
			print ("Speed: " , SPEED)
		get:
			return SPEED
			
var coins: int:
	set(value):
		if value < 0:
			value = 0
		coins = value
		coin_pickup_sound.play()
		coins_label.text = str("Coins: ", coins)


const JUMP_VELOCITY = 6.0
const MOUSE_SENSITIVITY = 0.1

var pickable_items: Array[Collectable] = []
var interactable_items: Array[Interactable] = []

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var original_cam_pos: Vector3


var bobbing_time: float
var bob_value: Vector2 = Vector2(SPEED / 200,  SPEED / 60)

@onready var camera = $Camera3D
@onready var main_label = $CanvasLayer/Label
@onready var coins_label = $CanvasLayer/CoinsLabel

@onready var coin_pickup_sound: AudioStreamPlayer = $Audio/CoinPickup
@onready var player_foot_sound: AudioStreamPlayer3D = $Audio/Playerfoot





func _ready():
	original_cam_pos = camera.position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	var cam_forward = -camera.global_transform.basis.z
	var cam_right = camera.global_transform.basis.x
	
	cam_forward.y = 0; cam_right.y = 0
	cam_forward = cam_forward.normalized(); cam_right = cam_right.normalized()
	
	var direction = (cam_right * input_dir.x + cam_forward * input_dir.y)
	
	if direction:
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		bobbing_time += delta * SPEED * 3
		camera.position = original_cam_pos + Vector3(cos(bobbing_time * 0.5) * bob_value.x,sin(bobbing_time) * bob_value.y, 0)

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		camera.position = camera.position.lerp(original_cam_pos, 0.05) 

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

		rotate_y(-event.relative.x * MOUSE_SENSITIVITY * PI / 180)
		camera.rotation.x = clamp(camera.rotation.x - event.relative.y * MOUSE_SENSITIVITY * PI / 180, -PI/2, PI/2)

func _unhandled_input(event):

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("ui_take"):
		if pickable_items.size() > 0:
			for item: Collectable in pickable_items:
				if item.type == 0: # Coin
					coins += 1
				else:
					pass
				item.visible = false
				item.process_mode = PROCESS_MODE_DISABLED
				pickable_items.erase(item)

			main_label.visible = false
			return
			
			
		if interactable_items.size() > 0:
			match interactable_items[0].type:
				1: #Exit Door
					get_tree().reload_current_scene()
				2: #Vending Machine
					if coins >= 3:
						coins -= 3
	

#__________________________AREA 3D________________________________________________
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Hollow:
		print("detected")
		body.seen = true
		print(body.seen)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Hollow:
		body.seen = false


func _on_pickable_area_body_entered(body: Node3D) -> void:	
	if body is Collectable and body.visible == true:
		main_label.visible = true
		main_label.text = "To take the Item press E"
		pickable_items.push_back(body)
	
	if body is Interactable and body.visible == true:
		main_label.visible = true
		main_label.text = "To interact press E"
		interactable_items.push_back(body)
		
func _on_pickable_area_body_exited(body: Node3D) -> void:
	if body is Collectable:
		pickable_items.erase(body)
		if pickable_items.size() == 0:
			main_label.visible = false
	
	if body is Interactable:
		interactable_items.erase(body)
		if interactable_items.size() == 0:
			main_label.visible = false
