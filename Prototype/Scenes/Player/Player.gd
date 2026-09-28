extends CharacterBody2D
class_name Player

var active_cutscene: bool = true

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var progress_jump: ProgressBar = $ProgressBar

@export var max_speed: float = 400.0
@export var acceleration: float = 500.0
@export var deceleration: float = 850.0

var previous_direction = 0
var camera_offset = 65

@export var min_jump_force: float = 300.0
@export var max_jump_force: float = 600.0
@export var jump_charge_time: float = 1.0

var jump_charge: float = 0.0
var charging_jump: bool = false
var was_on_floor: bool = false

@export var player_camera: Camera2D = null

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
		if player_camera.offset.x != offset_position:
			create_tween().tween_property(player_camera, "offset", Vector2(offset_position, -50), 0.7)
	
	move_and_slide()
	update_animation(direction)

func player_jump(direction) -> void:
	charging_jump = false
	
	var charge_ratio = jump_charge / jump_charge_time
	var jump_force = lerp(min_jump_force, max_jump_force, charge_ratio)
	velocity.x += jump_force * 0.5 * direction
	velocity.y = -jump_force
	jump_charge = 0.0

func update_animation(direction: float) -> void:
	if not is_on_floor():
		if anim_sprite.animation != "midair":
			anim_sprite.play("midair")
		anim_sprite.speed_scale = 1
		return
	
	if direction != 0:
		anim_sprite.flip_h = direction > 0
	
	var speed_ratio = abs(velocity.x) / max_speed
	anim_sprite.speed_scale = lerpf(0, 2.2, speed_ratio)
	
	if abs(velocity.x) > 1:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")
	
