extends Node2D

@export var dayTimer:Timer 

var minutes:int
var seconds:int
var chrono_label:String



@export var in_store : bool


func _process(delta):
	if in_store : 
		$MarginContainer/HBoxContainer/Timer/time.text = chrono_label
		minutes = int(dayTimer.time_left/60)
		seconds = dayTimer.time_left - minutes * 60
		chrono_label = str(minutes).pad_zeros(1) + ":" + str(seconds).pad_zeros(2)
