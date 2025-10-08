extends StaticBody2D

@onready var fire_particles: Node2D = $fire
@onready var area: Area2D = $Area2D
@onready var progress_bar: ProgressBar = $heat_bar

@export var cook_time: float = 10       # durée pour "cuire" un bois en nourriture
@export var wood_scene: PackedScene = preload("res://scenes/wood_item_chimney.tscn")
@export var food_scene: PackedScene = preload("res://scenes/food_item.tscn")

var player_near: bool = false
var cooking: bool = false
var cook_timer: float = 0.0

func _ready():
	if Global.kitchen_level <= 0:
		queue_free()
	progress_bar.value = 0
	fire_particles.visible = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if cooking:
		cook_timer += delta
		progress_bar.value = clamp((cook_timer / cook_time) * 100.0, 0, 100)

		if cook_timer >= cook_time:
			_finish_cooking()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false

func _input(event):
	# Empêche toute action si déjà en cuisson
	if player_near and Input.is_action_just_pressed("hit"):
		if not cooking:
			_try_start_cooking()

func _try_start_cooking():
	# Vérifie s'il reste du bois
	if Global.wood_stock <= 0:
	
		return

	# Si déjà en cuisson, on ignore
	if cooking:
	
		return

	# Consomme un seul bois et démarre la cuisson
	Global.wood_stock -= 1
	_start_cooking()

func _start_cooking():
	cooking = true
	cook_timer = 0.0
	fire_particles.visible = true
	progress_bar.value = 0

	# Animation du bois qui saute dans le feu
	var wood = wood_scene.instantiate()
	get_parent().add_child(wood)
	wood.global_position = Global.player.global_position
	var tween := wood.create_tween()
	tween.tween_property(wood, "global_position", global_position, 0.6)
	tween.tween_callback(Callable(wood, "queue_free"))

func _finish_cooking():
	cooking = false
	fire_particles.visible = false
	progress_bar.value = 100

	# Spawn la nourriture
	_spawn_food()

	# Petite pause visuelle avant de reset la barre
	await get_tree().create_timer(0.8).timeout
	progress_bar.value = 0

func _spawn_food():
	var food = food_scene.instantiate()
	get_parent().add_child(food)
	food.global_position = global_position + Vector2(0, -20)
	
