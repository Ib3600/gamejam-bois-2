extends StaticBody2D


var is_trading:bool
func _ready():
	is_trading = false
	$AnimatedSprite2D.play("default")

func _process(delta):
	$TextureRect.visible = is_trading
	

		
	


func _on_trade_zone_body_entered(body):
	if body.is_in_group("player"):
		is_trading = true


func _on_trade_zone_body_exited(body):
	if body.is_in_group("player"):
		is_trading = false
