extends Node2D

@export var move_speed: float = 100.0 
@export var drop_name:String

var target: Node2D = null  
func _ready():
	if Global.axe_collected == true and drop_name =="axe":
		queue_free()
	
func _process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * move_speed * delta

		
		if global_position.distance_to(target.global_position) < 10.0:
			match drop_name:
				"wood":
					target = null
					Global.wood_stock += 1
					queue_free()
				"food":
					target = null
					Global.food_stock += 1
					queue_free()
				"money":
					target = null
					Global.money += 1
					queue_free()
				"axe":
					target = null
					Global.axe_collected = true
					Global.niveu_hache += 1
					queue_free()

func _on_detect_player_body_entered(body):
	if body.is_in_group("player"):
		target = body
