extends Camera2D

@export var player:CharacterBody2D


func _ready():
	pass
	
func _process(delta):
	if player : 
		position = player.global_position
	
