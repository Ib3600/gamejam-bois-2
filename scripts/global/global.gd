extends Node2D

var wood_stock = 0
var food_stock = 0
var money_stock = 0
var heat_stock = 0.0
var heat_timer: Timer

func _ready():
	wood_stock = 10
	food_stock = 0
	money_stock = 0
	heat_stock = 20.0

	heat_timer = Timer.new()
	heat_timer.wait_time = 0.1      # toutes les 0.1 s
	heat_timer.one_shot = false
	heat_timer.autostart = true
	add_child(heat_timer)
	heat_timer.timeout.connect(_on_heat_timer_timeout)

func _on_heat_timer_timeout():
	heat_stock -= 0.1               # décrément progressif
	heat_stock = max(heat_stock, 0) # empêche de passer en négatif
