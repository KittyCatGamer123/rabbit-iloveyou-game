@tool
extends StaticBody2D

@onready var polygon_shape: Polygon2D = $Polygon2D
@onready var collision_shape: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_inspector().edited_object_changed.connect(update_collision_shape)
	
	update_collision_shape()

func update_collision_shape() -> void:
	collision_shape.position = polygon_shape.position
	collision_shape.polygon = polygon_shape.polygon
