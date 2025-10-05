extends Node2D

@export var move_speed: float = 100.0 
var target: Node2D = null  

func _process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * move_speed * delta

		
		if global_position.distance_to(target.global_position) < 10.0:
			target = null
			Global.wood_stock +=1
			queue_free()  


func _on_detect_player_body_entered(body):
	if body.is_in_group("player"):
		target = body
