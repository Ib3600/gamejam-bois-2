extends Node2D

@onready var dialogue = $dialogue

func _ready():
	Global.current_day = 3

	dialogue.queue_text("Jour 3")
	$dayTimer.start()
	



func _on_day_timer_timeout():
	dialogue.queue_text("Il va bientot faire nuit. Il est l'heure de revenir au chalet")
	dialogue.fade_to_black()
	Global.fin_de_journee()
	dialogue.change_scene("res://scenes/management menu.tscn")
