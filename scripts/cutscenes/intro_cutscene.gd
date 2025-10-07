extends Node2D


@onready var snowStorm:AnimationPlayer = $Camera2D/ColorRect2/snowStorm_animation
@onready var cameraAnim:AnimationPlayer= $Camera2D/camera_animation



func _ready():
	$environment/player.play("default")
	$environment/marchand.play("default")
	snowStorm= $Camera2D/ColorRect2/snowStorm_animation
	cameraAnim=$Camera2D/camera_animation

	cameraAnim.play("show_world")
	
