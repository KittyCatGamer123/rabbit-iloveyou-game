extends CharacterBody2D
class_name Player

var active_cutscene: bool = true

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var progress_jump: ProgressBar = $ProgressBar

@export var player_camera: Camera2D = null

@export_category("Speed")
@export var max_speed: float = 400.0
@export var acceleration: float = 500.0
@export var deceleration: float = 850.0

var previous_direction = 0
var camera_offset = 65

@export_category("Jumping")
@export var min_jump_force: float = 300.0
@export var max_jump_force: float = 600.0
@export var jump_charge_time: float = 1.0

var jump_charge: float = 0.0
var charging_jump: bool = false
var was_on_floor: bool = false

@export_category("Wallhopping")
@onready var rc_right_wall: RayCast2D = $Raycasts/RightWall
@onready var rc_left_wall: RayCast2D = $Raycasts/LeftWall

@export var wall_jump_enabled: bool = true
@export var wall_jump_force: Vector2 = Vector2(800, -400)
@export var wall_slide_velocity: float = 90.0
var is_wall_jumping: bool = false

func _ready() -> void:
	progress_jump.value = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction := Input.get_axis("left_movement", "right_movement")
	if active_cutscene:
		direction = 0
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
		previous_direction = sign(velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
	if is_on_floor() and not active_cutscene:
		progress_jump.value = jump_charge
		
		if Input.is_action_just_pressed("jump_action"):
			charging_jump = true
			jump_charge = 0.0
		
		if charging_jump:
			jump_charge += delta
			jump_charge = min(jump_charge, jump_charge_time)
			if Input.is_action_just_released("jump_action"):
				player_jump(direction)
	progress_jump.modulate = Color("ffffffff") if is_on_floor() else Color("ffffff4b")
	
	if player_camera and not active_cutscene:
		var offset_position = previous_direction * camera_offset
		move_camera_offset(offset_position)
	
	player_wallmovement()
	move_and_slide()
	update_animation(direction)

func player_jump(direction) -> void:
	charging_jump = false
	
	var charge_ratio = jump_charge / jump_charge_time
	var jump_force = lerp(min_jump_force, max_jump_force, charge_ratio)
	velocity.x += jump_force * 0.5 * direction
	velocity.y = -jump_force
	jump_charge = 0.0

func player_wallmovement() -> void:
	if is_on_wall_only():
		velocity.y = wall_slide_velocity
		
		if Input.is_action_just_pressed("jump_action") and wall_jump_enabled:
			if rc_left_wall.is_colliding():
				velocity = wall_jump_force
				has_walljumped()
				anim_sprite.flip_h = true
				previous_direction = 1
				move_camera_offset(camera_offset)
				
				create_tween().tween_property(anim_sprite, "rotation", TAU, 0.5).as_relative()
			
			if rc_right_wall.is_colliding():
				var inverse_force = Vector2(-wall_jump_force.x, wall_jump_force.y)
				velocity = inverse_force
				has_walljumped()
				anim_sprite.flip_h = false
				previous_direction = -1
				move_camera_offset(-camera_offset)
				
				create_tween().tween_property(anim_sprite, "rotation", -TAU, 0.5).as_relative()

func has_walljumped() -> void:
	is_wall_jumping = true
	await get_tree().create_timer(0.12).timeout
	is_wall_jumping = false

func update_animation(direction: float) -> void:
	if not is_on_floor():
		if anim_sprite.animation != "midair":
			anim_sprite.play("midair")
		anim_sprite.speed_scale = 1
		return
	
	if direction != 0:
		anim_sprite.flip_h = direction > 0
	
	var speed_ratio = abs(velocity.x) / max_speed
	anim_sprite.speed_scale = lerpf(0, 3, speed_ratio)
	
	if abs(velocity.x) > 1:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")

func move_camera_offset(offset_direction: float):
	if player_camera.offset.x != offset_direction:
			create_tween().tween_property(player_camera, "offset", Vector2(offset_direction, -50), 0.7)
