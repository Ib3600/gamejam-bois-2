extends Node2D


@onready var snowStorm:AnimationPlayer = $Camera2D/ColorRect2/snowStorm_animation
@onready var cameraAnim:AnimationPlayer



func _ready():
	$Camera2D/AnimationPlayer.play("end")

	
