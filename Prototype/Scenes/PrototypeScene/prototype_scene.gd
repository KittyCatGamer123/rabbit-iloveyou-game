extends Node2D

@onready var player: Player = $Player

var message_active = false
var message_awaiting_input = false
@onready var message_box: TextureRect = $CanvasLayer/MessageBox
@onready var message_box_text: Label = $CanvasLayer/MessageBox/Text
@onready var message_box_doneicon: Label = $CanvasLayer/MessageBox/CompleteIcon
@onready var explain_text: Label = $CanvasLayer/ExplainText

func _ready() -> void:
	message_box.visible = false
	await get_tree().create_timer(2.5).timeout
	await message_prompt("Little Nutbrown Hare, who was going to bed, wanted to be sure that Big Nutbrown Hare was listening.")
	message_remove()
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
	return

func message_remove():
	create_tween().tween_property(message_box_doneicon, "position", Vector2(960, 155.0), 0.5)
	create_tween().tween_property(message_box_doneicon, "self_modulate", Color(1, 1, 1, 0), 0.3)
	
	create_tween().tween_property(message_box_text, "self_modulate", Color(1, 1, 1, 0), 0.2)
	await create_tween().tween_property(message_box, "self_modulate", Color(1, 1, 1, 0), 0.4).finished
	message_box.visible = false
	

func explain_text_prompt(text):
	explain_text.visible = true
	explain_text.self_modulate = Color(1,1,1,0)
	explain_text.text = text
	await create_tween().tween_property(explain_text, "self_modulate", Color(1, 1, 1, 1), 0.65).finished

func explain_text_remove():
	await create_tween().tween_property(explain_text, "self_modulate", Color(1, 1, 1, 0), 0.65).finished
	explain_text.visible = false
