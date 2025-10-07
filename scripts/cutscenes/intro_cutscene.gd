extends Node2D


@onready var snowStorm:AnimationPlayer = $Camera2D/ColorRect2/snowStorm_animation
@onready var cameraAnim:AnimationPlayer



func _ready():
	$environment/player.play("default")
	$environment/marchand.play("default")
	snowStorm= $Camera2D/ColorRect2/snowStorm_animation
	cameraAnim=$Camera2D/camera_animation
	$Camera2D/camera_animation.play("show_world")

	if cameraAnim: 
		print("good")
	else : 
		print("bad")

	
