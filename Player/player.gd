class_name Player extends CharacterBody3D

var SPEED: float = 10.0:
		set(value):
			if value <= 1:
				SPEED = 1
			else:
				SPEED = value
			print ("Speed: " , SPEED)
		get:
			return SPEED
const JUMP_VELOCITY = 6.0
const MOUSE_SENSITIVITY = 0.1

var coins: int:
	set(value):
		if value < 0:
			value = 0
		coins = value
		coin_pickup_sound.play()
		coins_label.text = str("Coins: ", coins)

var pickable_items: Array[Collectable] = []
var interactable_items: Array[Interactable] = []
var inventory: Array[Collectable] = []
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var item_selected: bool
var selected_item: Collectable
var selected_item_rect: TextureRect

@onready var camera = $Camera3D
@onready var main_label = $CanvasLayer/Label
@onready var button_label = $CanvasLayer/ButtonLabel
@onready var coins_label = $CanvasLayer/CoinsLabel

@onready var coin_pickup_sound: AudioStreamPlayer = $Audio/CoinPickup
@onready var player_foot_sound: AudioStreamPlayer3D = $Audio/Playerfoot





func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	button_label.visible = false

func _physics_process(delta):
	$CanvasLayer/Label2.text = "FPS: " + str(Engine.get_frames_per_second())
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
		if not player_foot_sound.playing:
			player_foot_sound.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

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
		if inventory.size() < 5 and pickable_items.size() > 0:
			for item: Collectable in pickable_items:
				if inventory.size() < 5:
					if item.type == 0: # Coin
						coins += 1
					else:
						UIinventory_add(item)
					item.visible = false
					item.process_mode = PROCESS_MODE_DISABLED
					pickable_items.erase(item)
					inventory.push_back(item)

					SPEED -= item.weight
			main_label.visible = false
			return
		elif pickable_items.size() > 0:
			main_label.visible = true
			main_label.text = "Full inventory"
			
		if interactable_items.size() > 0:
			match interactable_items[0].type:
				1:
					get_tree().reload_current_scene()
				2: #Vending Machine
					coins -= 1
	
	if event.is_action_pressed("ui_remove"):
		print(item_selected and selected_item and selected_item_rect)
		if item_selected and selected_item and selected_item_rect:
			
			selected_item.process_mode = PROCESS_MODE_INHERIT
			selected_item.position = self.position + Vector3(2,4,2)
			print(selected_item.global_position, self.global_position)
			inventory.erase(selected_item)
			SPEED += selected_item.weight
			selected_item_rect.queue_free()
			
			selected_item.visible = true
			selected_item = null

			item_selected = false
			button_label.visible = false

func _on_item_button_pressed(item: Collectable, texture_rect: TextureRect, item_button:Button):
	
	button_label.global_position = Vector2(item_button.global_position.x, item_button.global_position.y - 50)
	button_label.visible = true
	item_selected = true
	selected_item = item
	selected_item_rect = texture_rect
	
func UIinventory_add(item) -> void:
	var texture_rect = TextureRect.new()
	var item_button = Button.new()
	texture_rect.texture = preload("res://icon.svg")
	$CanvasLayer/Items.add_child(texture_rect)
	texture_rect.add_child(item_button)
	item_button.scale = Vector2(16,16)
	item_button.modulate.a = 0
	item_button.name = "Button_" + str(item.get_instance_id())
	item_button.pressed.connect(_on_item_button_pressed.bind(item, texture_rect, item_button))
	
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
