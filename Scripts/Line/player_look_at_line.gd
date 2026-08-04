class_name PlayerLookAtLine extends CustomLine

var player_look_at_position: Sprite2D

func set_player_look_at_position_sprite(sprite: Sprite2D):
	player_look_at_position = sprite

func reset_path():
	super.reset_path()
	player_look_at_position.visible = false
