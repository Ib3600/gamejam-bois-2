extends Node2D

@onready var dialogue = $TextBox

func _ready():
	dialogue.queue_text("Jour 1")
	$dayTimer.start()


func _process(delta):
	print($dayTimer.time_left)
func _on_day_timer_timeout():
	
	dialogue.queue_text("Il va bientot faire nuit. Il est l'heure de revenir au chalet")
	dialogue.fade_to_black()
	dialogue.change_scene("")
