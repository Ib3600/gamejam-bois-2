extends Node2D

@onready var dialogue = $dialogue

func _ready():
	Global.current_day = 2

	dialogue.queue_text("Jour 2")
	$dayTimer.start()
	



func _on_day_timer_timeout():
	dialogue.queue_text("Il va bientot faire nuit. Il est l'heure de revenir au chalet")
	dialogue.fade_to_black()
	dialogue.change_scene("res://scenes/management menu.tscn")
