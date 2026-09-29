extends Node2D

var cutscene_skip = false

@onready var player: Player = $Player
@onready var player_cam: Camera2D = $Player/Camera2D

var message_active = false
var message_awaiting_input = false
@onready var message_box: TextureRect = $CanvasLayer/MessageBox
@onready var message_box_text: Label = $CanvasLayer/MessageBox/Text
@onready var message_box_doneicon: Label = $CanvasLayer/MessageBox/CompleteIcon
@onready var explain_text: Label = $CanvasLayer/ExplainText

func _ready() -> void:
	if cutscene_skip:
		player.active_cutscene = false
		return
	
	$BigRabbit.position = Vector2(1035, 65)
	$BigRabbit.flip_h = false
	message_box.visible = false
	
	await get_tree().create_timer(2.5).timeout
	create_tween().tween_property(player_cam, "offset", Vector2(0, -65), 0.5).set_ease(Tween.EASE_IN_OUT)
	await message_prompt("Little Nutbrown Hare, who was going to bed, wanted to be sure that Big Nutbrown Hare was listening.")
	
	message_remove()
	create_tween().tween_property(player_cam, "offset", Vector2(0, -40), 0.5).set_ease(Tween.EASE_IN_OUT)
	player.active_cutscene = false
	
	await get_tree().create_timer(1).timeout
	explain_text_prompt("W & D or Left Axis to Move")

func _input(event: InputEvent) -> void:
	if event.is_action_released("menu_confirm"):
		if message_awaiting_input:
			message_awaiting_input = false

func message_prompt(message: String):
	message_box_text.text = message
	message_box_text.visible_characters = 0
	
	if not message_active:
		message_active = true
		message_box.visible = true
		message_box.self_modulate = Color(1, 1, 1, 0)
		message_box_text.self_modulate = Color(1, 1, 1, 1)
		message_box_doneicon.self_modulate = Color(1, 1, 1, 0)
	
		await create_tween().tween_property(message_box, "self_modulate", Color(1, 1, 1, 0.6), 0.25).finished
		create_tween().tween_property(message_box, "self_modulate", Color(1, 1, 1, 1), 0.75)
	
	for n in len(message)+1:
		await get_tree().create_timer(0.02).timeout
		message_box_text.visible_characters = n
		if message[n-1] in [',']:
			await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(0.5).timeout
	message_awaiting_input = true
	
	create_tween().tween_property(message_box_doneicon, "position", Vector2(960, 165.0), 0.5)
	create_tween().tween_property(message_box_doneicon, "self_modulate", Color(1, 1, 1, 1), 0.5)
	
	while message_awaiting_input:
		await get_tree().process_frame
	
	message_awaiting_input = false
	create_tween().tween_property(message_box_doneicon, "position", Vector2(960, 155.0), 0.5)
	create_tween().tween_property(message_box_doneicon, "self_modulate", Color(1, 1, 1, 0), 0.3)
	return

func message_remove():
	create_tween().tween_property(message_box_text, "self_modulate", Color(1, 1, 1, 0), 0.2)
	await create_tween().tween_property(message_box, "self_modulate", Color(1, 1, 1, 0), 0.4).finished
	message_box.visible = false
	message_active = false

func explain_text_prompt(text):
	explain_text.visible = true
	explain_text.self_modulate = Color(1,1,1,0)
	explain_text.text = text
	await create_tween().tween_property(explain_text, "self_modulate", Color(1, 1, 1, 1), 0.65).finished

func explain_text_remove():
	await create_tween().tween_property(explain_text, "self_modulate", Color(1, 1, 1, 0), 0.65).finished
	explain_text.visible = false

func trigger_meetparent(body: Node2D) -> void:
	if body != player or cutscene_skip:
		return
	
	$"Trigger-MeetParent".set_deferred("monitoring", false)
	player.active_cutscene = true
	player.velocity.x = 0
	explain_text_remove()
	await get_tree().create_timer(1).timeout
	create_tween().tween_property(player_cam, "offset", Vector2(45, -65), 0.5).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(1).timeout
	await message_prompt("\"Guess how much I love you\" he said.")
	
	create_tween().tween_property(player_cam, "offset", Vector2(65, -65), 0.5).set_ease(Tween.EASE_IN_OUT)
	await message_prompt("\"Oh, I don't think I could guess that,\" said Big Nutbrown Hare.")
	
	message_remove()
	create_tween().tween_property(player_cam, "offset", Vector2(65, -40), 0.5).set_ease(Tween.EASE_IN_OUT)
	player.active_cutscene = false
	
	await get_tree().create_timer(1).timeout
	explain_text_prompt("Hold Space or the A button to power up your jump")
	

func trigger_stump1(body: Node2D) -> void:
	if body != player or cutscene_skip:
		return
	
	$"Trigger-Stump1".set_deferred("monitoring", false)
	player.active_cutscene = true
	player.velocity.x = 0
	explain_text_remove()
	player.anim_sprite.flip_h = false
	$BigRabbit.flip_h = true
	
	create_tween().tween_property(player_cam, "offset", Vector2(-60, -65), 0.7).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(1).timeout
	await message_prompt("\"This much,\" said Little Nutbrown Hare, stretching out his arms as wide as they go.")
	message_remove()
	
	await get_tree().create_timer(2).timeout
	$BigRabbit.play("run", 1)
	await create_tween().tween_property($BigRabbit, "position", Vector2(1155.0, 86), 1).set_ease(Tween.EASE_IN_OUT).finished
	create_tween().tween_property(player_cam, "offset", Vector2(-25, -55), 0.7).set_ease(Tween.EASE_IN_OUT)
	await create_tween().tween_property($BigRabbit, "position", Vector2(1360.0, 98.0), 1).set_ease(Tween.EASE_IN_OUT).finished
	player.anim_sprite.flip_h = true
	$BigRabbit.play("idle", 1)
	await get_tree().create_timer(1).timeout
