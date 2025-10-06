extends ColorRect



func _on_button_pressed():
	if Global.wood_stock >= 5 : 
		Global.wood_stock -= 5 
		Global.money +=1
