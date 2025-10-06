extends Label
@export var label_name:String

func _process(delta):
	match label_name : 
		"wood":
			text = str(Global.wood_stock)
		"food":
			text = str(Global.food_stock)
		"money":
			text = str(Global.money)
