extends Area2D

@export var health: int = 3
@export var attack_cooldown: float = 3.0
@export var attack_push_distance: float = 50.0
@export var attack_push_duration: float = 0.25

# --- Drops ---
@export var wood_drop: int = 10
@export var food_drop: int = 5

var wood_scene = preload("res://scenes/wood_item.tscn")
var food_scene = preload("res://scenes/food_item.tscn")
var particle_scene = preload("res://scenes/particles/mob_dying.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $attackCooldown
@onready var hitbox_attack = $hitbox_attack
@onready var hurtbox = $hurtbox
@onready var detect_player = $detect_player
@onready var stop_attacking = $stop_attacking

var player: Node2D = null
var is_attacking := false
var can_attack := true
var is_dead := false
var player_in_sight := false
var player_in_zone := false

# --------------------------------------------------
# READY
# --------------------------------------------------
func _ready():
	anim.play("idle")
	_disable_all_collisions()

	detect_player.connect("body_entered", Callable(self, "_on_detect_player_body_entered"))
	detect_player.connect("body_exited", Callable(self, "_on_detect_player_body_exited"))
	stop_attacking.connect("body_exited", Callable(self, "_on_stop_attacking_body_exited"))
	hurtbox.connect("area_entered", Callable(self, "_on_hurtbox_area_entered"))

	anim.connect("frame_changed", Callable(self, "_on_frame_changed"))
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))
	attack_timer.connect("timeout", Callable(self, "_on_attack_cooldown_timeout"))

# --------------------------------------------------
# PROCESS PRINCIPAL
# --------------------------------------------------
func _process(_delta):
	if is_dead:
		return
	
	if health <= 0:
		die()
		return

	# Si le joueur est présent dans la zone → attaque en boucle
	if player_in_sight and can_attack and not is_attacking:
		perform_attack()

# --------------------------------------------------
# ATTAQUE
# --------------------------------------------------
func perform_attack():
	is_attacking = true
	can_attack = false
	anim.play("attack")
	attack_timer.start(attack_cooldown)

func _on_frame_changed():
	if anim.animation == "attack":
		match anim.frame:
			1, 2, 3:
				_set_collision_active(hitbox_attack, "1_3", true)
				_set_collision_active(hitbox_attack, "4", false)
				_disable_hurtbox()
			4:
				_set_collision_active(hitbox_attack, "1_3", false)
				_set_collision_active(hitbox_attack, "4", true)
				_enable_hurtbox()
				_attack_push()
			_:
				_disable_all_collisions()

func _attack_push():
	var tween = create_tween()
	var forward = Vector2.RIGHT.rotated(rotation) * attack_push_distance
	var original_pos = global_position
	tween.tween_property(self, "global_position", original_pos + forward, attack_push_duration / 2)
	tween.tween_property(self, "global_position", original_pos, attack_push_duration / 2)

func _on_animation_finished():
	if anim.animation == "attack":
		is_attacking = false
		_disable_all_collisions()
		anim.play("idle")

func _on_attack_cooldown_timeout():
	can_attack = true

# --------------------------------------------------
# COLLISIONS
# --------------------------------------------------
func _set_collision_active(node: Node, name: String, active: bool):
	if node.has_node(name):
		var shape = node.get_node(name)
		if shape is CollisionShape2D or shape is CollisionPolygon2D:
			shape.disabled = not active

func _enable_hurtbox():
	for child in hurtbox.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = false

func _disable_hurtbox():
	for child in hurtbox.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = true

func _disable_all_collisions():
	for area in [hitbox_attack, hurtbox]:
		for child in area.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.disabled = true

# --------------------------------------------------
# DÉGÂTS ET MORT
# --------------------------------------------------
func _on_hurtbox_area_entered(area):
	if area.is_in_group("sword") and not is_dead:
		_take_damage()

func _take_damage():
	health -= 1
	anim.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)

func die():
	if is_dead:
		return
	is_dead = true
	anim.play("idle")
	spawn_particles()
	await spawn_wood_and_food()
	queue_free()

func spawn_particles():
	var particles = particle_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.emitting = true

func spawn_wood_and_food():
	for i in range(wood_drop):
		var wood = wood_scene.instantiate()
		get_parent().add_child(wood)
		var offset = Vector2(randf_range(-60, 60), randf_range(-60, 60))
		wood.global_position = global_position + offset
		await get_tree().create_timer(0.05).timeout

	for i in range(food_drop):
		var food = food_scene.instantiate()
		get_parent().add_child(food)
		var offset = Vector2(randf_range(-60, 60), randf_range(-60, 60))
		food.global_position = global_position + offset
		await get_tree().create_timer(0.05).timeout

# --------------------------------------------------
# DÉTECTION DU JOUEUR
# --------------------------------------------------
func _on_detect_player_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_in_sight = true
		player_in_zone = true

func _on_detect_player_body_exited(body):
	if body == player:
		player_in_sight = false

func _on_stop_attacking_body_exited(body):
	if body == player:
		player_in_zone = false
		player_in_sight = false
		player = null
