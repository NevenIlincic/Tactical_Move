extends Node2D

@onready var start_texture_rect: TextureRect = $Start_Texture_Rect
@onready var options_texture_rect: TextureRect = $Options_Texture_Rect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_texture_rect_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(start_texture_rect, "scale", Vector2(0.9, 0.5), 0.05).set_ease(Tween.EASE_IN)


func _on_start_texture_rect_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(start_texture_rect, "scale", Vector2(1.0, 0.5), 0.05).set_ease(Tween.EASE_OUT)


func _on_options_texture_rect_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(options_texture_rect, "scale", Vector2(0.9, 0.5), 0.05).set_ease(Tween.EASE_IN)


func _on_options_texture_rect_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(options_texture_rect, "scale", Vector2(1.0, 0.5), 0.05).set_ease(Tween.EASE_OUT)
